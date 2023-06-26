/**
 * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
 * © Copyright Utrecht University (Department of Information and Computing Sciences)
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

// Framework
import hre from "hardhat";
import { ethers, network } from "hardhat";
import fs from "fs";
import { createDiamondGovernanceRepo } from "../utils/diamondGovernanceHelper";

// Utils

// Types

// Other
import deployedDiamondGovernanceJson from "../generated/deployed_DiamondGovernance.json";
import diamondGovernanceRepoJson from "../generated/diamondGovernanceRepo.json";

/// This deployer deploys (and verifies) the Diamond Governance contracts and facets, it will only deploy the not already deployed contracts on the network.
/// In case contracts get changed (in deployment bytes), they will get redeployed.

const deployJsonFile = "./generated/deployed_DiamondGovernance.json";
const repoJsonFile = "./generated/diamondGovernanceRepo.json";

const additionalContracts : string[] = [
  "DiamondGovernanceSetup",
  "SignVerification",
];

const alwaysRedeploy : string[] = [
  "SignVerification",
];

const specialDeployment : { [contractName : string]: () => Promise<string> } = 
{ 
  SignVerification: async () => { 
    const SignVerificationContract = await ethers.getContractFactory("SignVerification");
    const SignVerification = await SignVerificationContract.deploy(60, 30);
    await SignVerification.deployed();

    if (!testing()) {
      console.log("Starting verification");
      // Wait for etherscan to process the deployment
      await new Promise(f => setTimeout(f, 10 * 1000));
      await hre.run("verify:verify", {
        address: SignVerification.address,
        constructorArguments: [60, 30],
      });
    }

    return SignVerification.address;
  },
}

export async function deployDiamondGovernance() : Promise<{ [contractName: string]: { address: string, fileHash: number } }> {
  const testDeploy = testing();
  const artifactNames = await hre.artifacts.getAllFullyQualifiedNames();
  const contractsToDeploy = artifactNames.filter(name => shouldDeploy(name));
  let allDeployments = getDeployment();
  let deployments : { [contractName : string]: { address: string, fileHash: number } } = { };
  if (allDeployments.hasOwnProperty(network.name)) {
    deployments = allDeployments[network.name];
  }
  for (let i = 0; i < contractsToDeploy.length; i++) {
    const contractName = getContractName(contractsToDeploy[i]);
    if (!testDeploy) {
      console.log("Deploying", contractName);
    }

    let address = ethers.constants.AddressZero;
    if (specialDeployment.hasOwnProperty(contractName)) {
      address = await specialDeployment[contractName]();
    }
    else {
      const contract = await ethers.getContractFactory(contractName);
      const deployment = await contract.deploy();
      await deployment.deployed();
      address = deployment.address;

      if (!testDeploy) {
        console.log("Starting verification");
        // Wait for etherscan to process the deployment
        await new Promise(f => setTimeout(f, 10 * 1000));
        try {
          await hre.run("verify:verify", {
            address: deployment.address,
            constructorArguments: [],
            contract: contractsToDeploy[i],
          });
        } catch { }
      }
    }

    const artifact = await hre.artifacts.readArtifact(contractsToDeploy[i]);
    deployments[contractName] = { address: address, fileHash: getHash(artifact.bytecode) };

    if (!testDeploy) {
      console.log("Deployed", contractName, "at", address);
      
      allDeployments[network.name] = deployments;
      fs.writeFileSync(deployJsonFile, JSON.stringify(allDeployments));
    }
  }
  return deployments;
}

export async function createDiamondGovernanceRepoIfNotExists() {
  let existingRepos: { [networkName: string]: { repo: string } } = diamondGovernanceRepoJson;
  if (existingRepos.hasOwnProperty(network.name)) { return; }

  const [owner] = await ethers.getSigners();
  const repo = await createDiamondGovernanceRepo("plugin" + Math.round(Math.random() * 100000), owner);
  existingRepos[network.name] = { repo: repo };
  fs.writeFileSync(repoJsonFile, JSON.stringify(existingRepos));
}

function testing() {
  return network.name == "hardhat";
}

function getDeployment() : { [networkName: string]: { [contractName : string]: { address: string, fileHash: number } } } {
  return deployedDiamondGovernanceJson;
}

// source: https://stackoverflow.com/questions/7616461/generate-a-hash-from-string-in-javascript
function getHash(str : string) : number {
  return str.split('').reduce((prevHash, currVal) =>
    (((prevHash << 5) - prevHash) + currVal.charCodeAt(0))|0, 0);
}

function getContractName(artifactName : string) : string {
  return artifactName.split(":")[1];
}

function shouldDeploy(artifactName : string) : boolean {
  return  ( 
            (
              isDeployable(artifactName) &&
              isFacet(artifactName) &&
              !isExample(artifactName) &&
              (testing() || !isTestOnly(artifactName))
            )
            || additionalContracts.includes(getContractName(artifactName))
          ) &&
          (!alreadyDeployed(artifactName) || isChanged(artifactName));
}

function isFacet(artifactName : string) : boolean {
  return artifactName.endsWith("Facet");
}

// Examples should not be deployed in DiamondGoverance, in case they need to be deployed for testing, create your onw deploy script
function isExample(artifactName : string) : boolean {
  return artifactName.includes("examples");
}

function isTestOnly(artifactNames : string) : boolean {
  return artifactNames.includes("testing");
}

// Interfaces and abstract contract should start with an I followed by a capital letter
function isDeployable(artifactName : string) : boolean {
  const interfaceRegex = new RegExp("^I[A-Z]");
  return !interfaceRegex.test(getContractName(artifactName));
}

// Check if the contract is already deployed on this network
// Note: redeployed anyway if on local hardhat network
function alreadyDeployed(artifactName : string) : boolean {
  if (testing()) {
    return false;
  }

  const deployment = getDeployment();
  if (!deployment.hasOwnProperty(network.name)) {
    // Network doesnt have any deployments
    return false;
  }

  return deployment[network.name].hasOwnProperty(getContractName(artifactName));
}

// Check if the contract is already deployed on this network
function isChanged(artifactName : string) : boolean {
  const contractName = getContractName(artifactName);
  if (alwaysRedeploy.includes(contractName)) {
    // Pretend it is changed to redeploy
    return true;
  }

  const deployment = getDeployment();
  if (!deployment.hasOwnProperty(network.name)) {
    // Network doesnt have any deployments
    return false;
  }

  if (!deployment[network.name].hasOwnProperty(contractName)) {
    // Contract not deployed yet
    return false;
  }

  const artifact = hre.artifacts.readArtifactSync(artifactName);
  if (deployment[network.name][contractName].fileHash !== getHash(artifact.bytecode)) {
    // Possibly change this into a Y/n console prompt (with of course option to accept/reject all)
    console.log("Detected changes to", contractName, "compared to latest deployment. Redeploying...");
    return true;
  }
  return false;
}
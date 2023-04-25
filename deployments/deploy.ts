/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  *
  * This source code is licensed under the MIT license found in the
  * LICENSE file in the root directory of this source tree.
  */

import { deployAragonDAO } from "./deploy_AragonDAO";
import { AragonOSxFrameworkContracts, ENSFrameworkContracts } from "./deploy_AragonOSxFramework";
import { ethers, network } from "hardhat";
import fs from "fs";

async function main() {
  console.log("Deploying to ", network.name);
  const ensFramework = await getExistingENSFramework();
  const aragonOSxFramework = await getExistingAragonOSxFramework();
  const deploy = await deployAragonDAO(aragonOSxFramework);
  console.log("DAO at: ", deploy.DAO.address);
  console.log("Diamond Governance at: ", deploy.DiamondGovernance.address);
  console.log("Deploy finished!");
}

/**
 * @returns The existing ENSFramework contracts
 */
async function getExistingENSFramework() : Promise<ENSFrameworkContracts> {
  const path = "./deployments/existing-contracts/existing_ENSFramework.json";
  const fileContent = fs.readFileSync(path, "utf-8");
  const fileContentParsed = JSON.parse(fileContent);
  if (!fileContentParsed.hasOwnProperty(network)) {
    throw new Error(`Network ${network} doesnt exist in ${path}`);
  }
  const existingContractAddresses = fileContentParsed[network.name];
  return {
    ens: await ethers.getContractAt("ENS", existingContractAddresses.ens),
    daoResolver: await ethers.getContractAt("PublicResolver", existingContractAddresses.daoResolver),
    pluginResolver: await ethers.getContractAt("PublicResolver", existingContractAddresses.pluginResolver),
  }
}

/**
 * @returns The existing AragonOSxFramework contracts
 */
async function getExistingAragonOSxFramework() : Promise<AragonOSxFrameworkContracts> {
  const path = "./deployments/existing-contracts/existing_AragonOSxFramework.json";
  const fileContent = fs.readFileSync(path, "utf-8");
  const fileContentParsed = JSON.parse(fileContent);
  if (!fileContentParsed.hasOwnProperty(network)) {
    throw new Error(`Network ${network} doesnt exist in ${path}`);
  }
  const existingContractAddresses = fileContentParsed[network.name];
  return {
    ManagingDAO: await ethers.getContractAt("DAO", existingContractAddresses.managingDAO),
    DAO_ENSSubdomainRegistrar: await ethers.getContractAt("ENSSubdomainRegistrar", existingContractAddresses.DAO_ENSSubdomainRegistrar),
    Plugin_ENSSubdomainRegistrar: await ethers.getContractAt("ENSSubdomainRegistrar", existingContractAddresses.Plugin_ENSSubdomainRegistrar),
    DAORegistry: await ethers.getContractAt("DAORegistry", existingContractAddresses.DAORegistry),
    PluginRepoRegistry: await ethers.getContractAt("PluginRepoRegistry", existingContractAddresses.PluginRepoRegistry),
    PluginRepoFactory: await ethers.getContractAt("PluginRepoFactory", existingContractAddresses.PluginRepoFactory),
    PluginSetupProcessor: await ethers.getContractAt("PluginSetupProcessor", existingContractAddresses.PluginSetupProcessor),
    DAOFactory: await ethers.getContractAt("DAOFactory", existingContractAddresses.DAOFactory),
  }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
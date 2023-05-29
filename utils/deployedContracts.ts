/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  *
  * This source code is licensed under the MIT license found in the
  * LICENSE file in the root directory of this source tree.
  */

import { ENSFrameworkContracts, AragonOSxFrameworkContracts } from "../deployments/deploymentTypes";
import { Signer } from "@ethersproject/abstract-signer";
import { GetTypedContractAt, GetContractAt, NamedContract } from "./contractHelper";
import { DAO, DAOFactory, DAORegistry, ENS, ENSSubdomainRegistrar, PluginRepoFactory, PluginRepoRegistry, PluginSetupProcessor, PublicResolver } from "../typechain-types";
import { DiamondGovernanceJson } from "./jsonTypes";

import deployed_ENSFrameworkJson from "../deployments/deployed-contracts/deployed_ENSFramework.json";
import deployed_AragonOSxFrameworkJson from "../deployments/deployed-contracts/deployed_AragonOSxFramework.json";
import deployed_DiamondGovernanceJson from "../generated/deployed_DiamondGovernance.json";
import DiamondGovernanceRepoJson from "../generated/diamondGovernanceRepo.json";

let deployedENS: ENSFrameworkContracts | undefined;
let deployedAragon: AragonOSxFrameworkContracts | undefined;
let deployedDiamondGovernance: any | undefined;
let diamondGovernanceRepo: string;

export function setDeployedENS(_deployedENS : ENSFrameworkContracts) {
    deployedENS = _deployedENS;
}

export function setDeployedAragon(_deployedAragon : AragonOSxFrameworkContracts) {
    deployedAragon = _deployedAragon;
}

export async function setDeployedDiamondGovernance(_deployedDiamondGovernanceJson : DiamondGovernanceJson, signer : Signer) {
    deployedDiamondGovernance = await diamondGovernanceJsonToContracts(_deployedDiamondGovernanceJson, signer);
}

export function setDiamondGovernanceRepo(_diamondGovernanceRepo : string) {
    diamondGovernanceRepo = _diamondGovernanceRepo;
}

// Convert from network provider name to human-readable name
function networkName(providerName : string) : string {
    switch (providerName) {
        case "maticmum":
            return "mumbai";
        case "unknown":
            // Questionnable
            return "hardhat";
        default:
            return providerName;
    }
}

/**
 * @returns The ENSFramework contracts
 */
export async function getDeployedENSFramework(signer : Signer) : Promise<ENSFrameworkContracts> {
    if (deployedENS != undefined) {
        return deployedENS;
    }

    const providerNetwork = await signer.provider?.getNetwork();
    if (providerNetwork == undefined) {
        throw new Error("Undefined network");
    }
    const network = networkName(providerNetwork.name);

    const deployedContracts : { [networkName : string]: any } = deployed_ENSFrameworkJson;
    if (!deployedContracts.hasOwnProperty(network)) {
        throw new Error(`Network ${network} doesnt exist in known deployed ENS frameworks`);
    }
    const existingContractAddresses = deployedContracts[network];
    deployedENS = {
        ens: await GetTypedContractAt<ENS>("ENS", existingContractAddresses.ens, signer),
        daoResolver: await GetTypedContractAt<PublicResolver>("PublicResolver", existingContractAddresses.daoResolver, signer),
        pluginResolver: await GetTypedContractAt<PublicResolver>("PublicResolver", existingContractAddresses.pluginResolver, signer),
    };
    return deployedENS;
  }
  
  /**
   * @returns The AragonOSxFramework contracts
   */
  export async function getDeployedAragonOSxFramework(signer : Signer) : Promise<AragonOSxFrameworkContracts> {
    if (deployedAragon != undefined) {
        return deployedAragon;
    }

    const providerNetwork = await signer.provider?.getNetwork();
    if (providerNetwork == undefined) {
        throw new Error("Undefined network");
    }
    const network = networkName(providerNetwork.name);

    const deployedContracts : { [networkName : string]: any } = deployed_AragonOSxFrameworkJson;
    if (!deployedContracts.hasOwnProperty(network)) {
        throw new Error(`Network ${network} doesnt exist in known deployed AragonOSx frameworks`);
    }
    const existingContractAddresses = deployedContracts[network];
    deployedAragon = {
        ManagingDAO: await GetTypedContractAt<DAO>("DAO", existingContractAddresses.managingDAO, signer),
        DAO_ENSSubdomainRegistrar: await GetTypedContractAt<ENSSubdomainRegistrar>("ENSSubdomainRegistrar", existingContractAddresses.DAO_ENSSubdomainRegistrar, signer),
        Plugin_ENSSubdomainRegistrar: await GetTypedContractAt<ENSSubdomainRegistrar>("ENSSubdomainRegistrar", existingContractAddresses.Plugin_ENSSubdomainRegistrar, signer),
        DAORegistry: await GetTypedContractAt<DAORegistry>("DAORegistry", existingContractAddresses.DAORegistry, signer),
        PluginRepoRegistry: await GetTypedContractAt<PluginRepoRegistry>("PluginRepoRegistry", existingContractAddresses.PluginRepoRegistry, signer),
        PluginRepoFactory: await GetTypedContractAt<PluginRepoFactory>("PluginRepoFactory", existingContractAddresses.PluginRepoFactory, signer),
        PluginSetupProcessor: await GetTypedContractAt<PluginSetupProcessor>("PluginSetupProcessor", existingContractAddresses.PluginSetupProcessor, signer),
        DAOFactory: await GetTypedContractAt<DAOFactory>("DAOFactory", existingContractAddresses.DAOFactory, signer),
    };
    return deployedAragon;
}

 /**
   * @returns The DiamondGovernance contracts
   */
 export async function getDeployedDiamondGovernance(signer : Signer) : Promise<any> {
    if (deployedDiamondGovernance != undefined) {
        return deployedDiamondGovernance;
    }

    const providerNetwork = await signer.provider?.getNetwork();
    if (providerNetwork == undefined) {
        throw new Error("Undefined network");
    }
    const network = networkName(providerNetwork.name);

    const deployedContracts : { [networkName : string]: DiamondGovernanceJson } = deployed_DiamondGovernanceJson;
    if (!deployedContracts.hasOwnProperty(network)) {
        throw new Error(`Network ${network} doesnt exist in known deployed Diamond Governance frameworks`);
    }
    const existingContractAddresses = deployedContracts[network];
    deployedDiamondGovernance = await diamondGovernanceJsonToContracts(existingContractAddresses, signer);
    return deployedDiamondGovernance;
}

export async function getDiamondGovernanceRepo(signer : Signer)  : Promise<string> {
    if (diamondGovernanceRepo != undefined) {
        return diamondGovernanceRepo;
    }

    const providerNetwork = await signer.provider?.getNetwork();
    if (providerNetwork == undefined) {
        throw new Error("Undefined network");
    }
    const network = networkName(providerNetwork.name);

    const deployedContracts : { [networkName : string]: { repo: string; } } = DiamondGovernanceRepoJson;
    if (!deployedContracts.hasOwnProperty(network)) {
        throw new Error(`Network ${network} doesnt exist in known Diamond Governance repos`);
    }
    const existingContractAddresses = deployedContracts[network];
    diamondGovernanceRepo = existingContractAddresses.repo;
    return diamondGovernanceRepo;
}

async function diamondGovernanceJsonToContracts(diamondGovernanceJson : DiamondGovernanceJson, signer : Signer) : Promise<{ [contractName : string]: NamedContract }> {
    const contractNames = Object.keys(diamondGovernanceJson);
    const diamondGovernance : { [contractName : string]: NamedContract } = { };
    for (let i = 0; i < contractNames.length; i++) {
        const contractName = contractNames[i];
        diamondGovernance[contractName] = await GetContractAt(contractName, diamondGovernanceJson[contractName].address, signer); 
    }
    return diamondGovernance;
}
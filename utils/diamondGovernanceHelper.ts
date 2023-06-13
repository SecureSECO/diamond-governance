/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  *
  * This source code is licensed under the MIT license found in the
  * LICENSE file in the root directory of this source tree.
  */

import { getSelectors, Selectors } from "./diamondHelper";
import { ethers, Contract } from "ethers";
import { Signer } from "@ethersproject/abstract-signer"
import { DAO, DAOFactory, DiamondGovernance, IDiamondCut } from "../typechain-types";
import { GetTypedContractAt, NamedContract } from "./contractHelper";

import { getDeployedAragonOSxFramework, getDeployedDiamondGovernance, getDiamondGovernanceRepo } from "../utils/deployedContracts";
import { toBytes, getEvents } from "../utils/utils";
import { addToIpfs } from "../utils/ipfsHelper";

import buildMetadataJson from "../contracts/build-metadata.json";
import releaseMetadataJson from "../contracts/release-metadata.json";

/// Helper for Diamond Governance operations, such as cutting and creating DAOs with the plugin.

export enum DiamondCutAction { Add, Replace, Remove, AddWithInit, RemoveWithDeinit }

export class DiamondCut {
    private facet : Contract | undefined;
    private action : DiamondCutAction;
    private methods : Selectors;
    private params: string;

    private constructor() {
        this.facet = undefined;
        this.action = DiamondCutAction.Add;
        this.methods = new Selectors([], undefined);
        this.params = "";
    }

    public static async All(facet : NamedContract, params : any[] = [], action : DiamondCutAction = DiamondCutAction.AddWithInit) : Promise<DiamondCut> {
        let diamondCut = new DiamondCut();
        diamondCut.facet = facet;
        diamondCut.action = action;
        diamondCut.methods = getSelectors(facet);
        if (action == DiamondCutAction.AddWithInit) {
            const expectedInternalInitStart = `__${facet.contractName}_init`;
            const internalInitName = Object.keys(facet.interface.functions).find(f => f.startsWith(expectedInternalInitStart));

            if (params.length > 0 && internalInitName == undefined) {
                throw new Error(`Could not find init method (${expectedInternalInitStart}). Does this faucet require initing? Otherwise give params = [] or change action`);
            }
            const inputs = internalInitName == undefined ? [] : facet.interface.functions[internalInitName].inputs;
            if (params.length == 0 && inputs.length > 0) {
                throw new Error(`Params not provided, but there is a init method (${expectedInternalInitStart}) present. Please provide params. (${inputs})`);
            }

            try {
                const paramBytes = facet.interface._abiCoder.encode(inputs, params);
                diamondCut.params = facet.interface.encodeFunctionData("init(bytes)", [paramBytes]);
            } catch (error) {
                console.log("Error while encoding", expectedInternalInitStart, "with", params);
                throw error;
            }
        } else if (action == DiamondCutAction.RemoveWithDeinit) {
            diamondCut.params = facet.interface.encodeFunctionData("deinit()", []);
        } else {
            diamondCut.params = "0x";
        }
        return diamondCut;
    }

    public static async Only(facet : NamedContract, methods : string[], params : any[] = [], action : DiamondCutAction = DiamondCutAction.AddWithInit) : Promise<DiamondCut> {
        let diamondCut = await DiamondCut.All(facet, params, action);
        diamondCut.methods = diamondCut.methods.get(methods);
        return diamondCut;
    }

    public static async Except(facet : NamedContract, methods : string[], params : any[] = [], action : DiamondCutAction = DiamondCutAction.AddWithInit) : Promise<DiamondCut> {
        let diamondCut = await DiamondCut.All(facet, params, action);
        diamondCut.methods = diamondCut.methods.remove(methods);
        return diamondCut;
    }

    public ToBlockchain() : IDiamondCut.FacetCutStruct {
        return {
            facetAddress: this.facet?.address ?? ethers.constants.AddressZero,
            action: this.action,
            functionSelectors: this.methods.selectors,
            initCalldata: this.params,
        }
    }
}


/**
 * Registers DiamondGoverannce with the Aragon PluginRepoFactory
 * @returns The address of the newly created PluginRepo
 */
export async function createDiamondGovernanceRepo(ensSubdomain : string, signer : Signer) : Promise<string> {
    const buildMetadata = JSON.stringify(buildMetadataJson);
    const releaseMetadata = JSON.stringify(releaseMetadataJson);
    const buildMetadataUri = "ipfs://" + await addToIpfs(buildMetadata);
    const releaseMetadataUri = "ipfs://" + await addToIpfs(releaseMetadata);

    const aragonOSxFramework = await getDeployedAragonOSxFramework(signer);
    const diamondGovernance = await getDeployedDiamondGovernance(signer);
  
    const tx = await aragonOSxFramework.PluginRepoFactory.createPluginRepoWithFirstVersion(
      ensSubdomain,
      diamondGovernance.DiamondGovernanceSetup.address,
      await signer.getAddress(),
      toBytes(buildMetadataUri),
      toBytes(releaseMetadataUri)
    );
    const receipt = await tx.wait();
    const PluginRepoAddress = getEvents(
      aragonOSxFramework.PluginRepoRegistry,
      "PluginRepoRegistered",
      receipt
    )[0].args.pluginRepo;
  
    return PluginRepoAddress;
}

export interface DiamondGovernanceDAO {
    dao: DAO;
    diamondGovernance: DiamondGovernance; 
}

export interface DAOCreationSettings {
    trustedForwarder: string, //address
    daoURI: string, //string
    subdomain: string, //string
    metadata: DAOMetadata,
    diamondCut : DiamondCut[],
    additionalPlugins : string[] //PluginInstallation[]
}

export interface DAOMetadata {
    name: string;
    description: string;
    links : { name: string, url: string }[]
    avatar: string; //or file and upload ipfs in create?
}

export async function CreateDAO(settings : DAOCreationSettings, signer : Signer) : Promise<DiamondGovernanceDAO> {
    const aragonOSxFramework = await getDeployedAragonOSxFramework(signer);
    const metadataUri = "ipfs://" + await addToIpfs(JSON.stringify(settings.metadata));
    const repo = await getDiamondGovernanceRepo(signer);

    const constructionFormat = buildMetadataJson.pluginSetupABI.prepareInstallation;
    const pluginConstructionBytes = ethers.utils.defaultAbiCoder.encode(
        constructionFormat,
        [
            settings.diamondCut.map(c => c.ToBlockchain())
        ]
    );

    const tag = {
        release: 1, //uint8
        build: 1, //uint16
    };

    const pluginSetupRef = {
        versionTag: tag, //PluginRepo.Tag
        pluginSetupRepo: repo, //PluginRepo
    };

    const diamondGovernancePluginSettings = {
        pluginSetupRef: pluginSetupRef, //PluginSetupRef
        data: pluginConstructionBytes, //bytes
    };
    
    const DAOFactorySettings : DAOFactory.DAOSettingsStruct = {
        trustedForwarder: settings.trustedForwarder,
        daoURI: settings.daoURI,
        subdomain: settings.subdomain,
        metadata: toBytes(metadataUri),
    }

    // Create DAO
    const tx = await aragonOSxFramework.DAOFactory.createDao(DAOFactorySettings, [diamondGovernancePluginSettings]);
    const receipt = await tx.wait();

    // Retrieve addresses from DAO creation log
    const DAOAddress = getEvents(aragonOSxFramework.DAORegistry, "DAORegistered", receipt)[0].args.dao;
    const pluginAddresses = getEvents(aragonOSxFramework.PluginSetupProcessor, "InstallationApplied", receipt).map((log : any) => log.args.plugin);
    
    // Link DAO and plugin address to Contracts
    const DAO = await GetTypedContractAt<DAO>("DAO", DAOAddress, signer);
    const DiamondGovernance = await GetTypedContractAt<DiamondGovernance>("DiamondGovernance", pluginAddresses[0], signer);

    return {
        dao: DAO,
        diamondGovernance: DiamondGovernance
    };
}
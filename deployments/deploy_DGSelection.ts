/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  *
  * This source code is licensed under the MIT license found in the
  * LICENSE file in the root directory of this source tree.
  */

// Framework
import { ethers } from "hardhat";
import fs from "fs";

// Utils
import { getSelectors, FacetCutAction } from "../utils/diamondHelper";
import { resolveENS } from "../utils/ensHelper";
import { days } from "../utils/timeUnits";
import { toBytes } from "../utils/utils";

// Types
import { AragonAuth, DAOReferenceFacet, DiamondGovernanceSetup, DIInterfaces, DiamondLoupeFacet, PluginFacet, PluginRepoFactory, PublicResolver } from "../typechain-types";

// Other
import { deployLibraries } from "./deploy_Libraries";

interface DiamondDeployedContracts {
  DiamondGovernanceSetup: DiamondGovernanceSetup;
  DIInterfaces: DIInterfaces;
  Facets: {
    DiamondLoupe: DiamondLoupeFacet;
    DAOReference: DAOReferenceFacet;
    Plugin: PluginFacet;
    AragonAuth: AragonAuth;
    AdditionalFacets: any[];
  }
}

/**
 * Deploys the PartialTokenBurnVotingSetup contract and registers it with the pluginRepoFactory
 * @param pluginRepoFactory The PluginRepoFactory to register with
 * @param pluginResolver The ENS resolver to get the plugin contract from afterwards
 * @returns The PluginSettings for installation in a DAO
 */
async function createDiamondGovernanceRepo(pluginRepoFactory : PluginRepoFactory, pluginResolver : PublicResolver, verificationContractAddress: string) {
  const buildMetadata = fs.readFileSync("./contracts/build-metadata.json", "utf8");
  const releaseMetadata = fs.readFileSync("./contracts/release-metadata.json", "utf8");
  const diamondGovernanceContracts = await deployDGBase();
  const [owner] = await ethers.getSigners();

  await pluginRepoFactory.createPluginRepoWithFirstVersion(
    "my-plugin",
    diamondGovernanceContracts.DiamondGovernanceSetup.address,
    owner.address,
    toBytes("https://plopmenz.com/buildMetadata"),
    toBytes("https://plopmenz.com/releaseMetadata")
  );
  const PluginRepoAddress = await resolveENS(pluginResolver, "plugin", "my-plugin");

  let cut = [];
  cut.push({
    facetAddress: diamondGovernanceContracts.Facets.DiamondLoupe.address,
    action: FacetCutAction.Add,
    functionSelectors: getSelectors(diamondGovernanceContracts.Facets.DiamondLoupe)
  });
  cut.push({
    facetAddress: diamondGovernanceContracts.Facets.DAOReference.address,
    action: FacetCutAction.Add,
    functionSelectors: getSelectors(diamondGovernanceContracts.Facets.DAOReference)
  });
  cut.push({
    facetAddress: diamondGovernanceContracts.Facets.AragonAuth.address,
    action: FacetCutAction.Add,
    functionSelectors: getSelectors(diamondGovernanceContracts.Facets.AragonAuth)
  });
  cut.push({
    facetAddress: diamondGovernanceContracts.Facets.Plugin.address,
    action: FacetCutAction.Add,
    functionSelectors: getSelectors(diamondGovernanceContracts.Facets.Plugin)
  });

  const constructionArgs = {
    _diamondCut: cut,
    _init: diamondGovernanceContracts.DIInterfaces.address,
    _calldata: diamondGovernanceContracts.DIInterfaces.interface.encodeFunctionData("init")
  };
  const constructionFormat = JSON.parse(buildMetadata).pluginSetupABI.prepareInstallation;
  const pluginConstructionBytes = ethers.utils.defaultAbiCoder.encode(
    constructionFormat,
    [constructionArgs._diamondCut, constructionArgs._init, constructionArgs._calldata]
  );

  const tag = {
      release: 1, //uint8
      build: 1 //uint16
  };
  
  const pluginSetupRef = {
      versionTag: tag, //PluginRepo.Tag
      pluginSetupRepo: PluginRepoAddress //PluginRepo
  };
  
  const diamondGovernancePluginSettings = {
      pluginSetupRef: pluginSetupRef, //PluginSetupRef
      data: pluginConstructionBytes //bytes
  };

  return { diamondGovernancePluginSettings, diamondGovernanceContracts, verificationContractAddress };
}

async function deployDGBase() : Promise<DiamondDeployedContracts> {
  // TODO: Change this later
  const libraries = await deployLibraries();

  const DiamondGovernanceSetupContract = await ethers.getContractFactory("DiamondGovernanceSetup", {
    libraries: {
      DAOReferenceFacetInit: libraries.DAOReferenceFacetInit
    }
  });
  const DiamondGovernanceSetup = await DiamondGovernanceSetupContract.deploy();
  console.log(`DiamondGovernanceSetup deployed at ${DiamondGovernanceSetup.address}`);
  
  // Deploy base DiamondInit (for the unimplemented interfaces)
  // This is a placeholder contract and should not be used in production
  // DiamondInit provides a function that is called when the diamond is upgraded to initialize state variables
  // Read about how the diamondCut function works here: https://eips.ethereum.org/EIPS/eip-2535#addingreplacingremoving-functions
  const DIInterfacesContract = await ethers.getContractFactory("DIInterfaces");
  
  const DIInterfaces = await DIInterfacesContract.deploy();
  console.log(`DIInterfaces deployed at ${DIInterfaces.address}`);

  // Facets
  const DiamondLoupeFacetContract = await ethers.getContractFactory("DiamondLoupeFacet");
  const DiamondLoupeFacet = await DiamondLoupeFacetContract.deploy();
  console.log(`DiamondLoupeFacet deployed at ${DiamondLoupeFacet.address}`);

  const DAOReferenceFacetContract = await ethers.getContractFactory("DAOReferenceFacet");
  const DAOReferenceFacet = await DAOReferenceFacetContract.deploy();
  console.log(`DAOReferenceFacet deployed at ${DAOReferenceFacet.address}`);
  
  const PluginFacetContract = await ethers.getContractFactory("PluginFacet");
  const PluginFacet = await PluginFacetContract.deploy();
  console.log(`PluginFacet deployed at ${PluginFacet.address}`);
  
  const AragonAuthContract = await ethers.getContractFactory("AragonAuth");
  const AragonAuth = await AragonAuthContract.deploy();
  console.log(`AragonAuth deployed at ${AragonAuth.address}`);

  return {
    DiamondGovernanceSetup: DiamondGovernanceSetup,
    DIInterfaces: DIInterfaces,
    Facets: {
      DiamondLoupe: DiamondLoupeFacet,
      DAOReference: DAOReferenceFacet,
      Plugin: PluginFacet,
      AragonAuth: AragonAuth,
      AdditionalFacets: [],
    }
  };
}

async function addFacetToDiamond (diamondGovernanceContracts: DiamondDeployedContracts, contractName: string) {
  // Catch error if contractName is invalid
  const facetContract = await ethers.getContractFactory(contractName);
  const facet = await facetContract.deploy();
  console.log(`${contractName} deployed at ${facet.address}`);

  diamondGovernanceContracts.Facets.AdditionalFacets.push(facet);
}

export { deployDGBase, createDiamondGovernanceRepo }
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
import { AragonAuth, DAOReferenceFacet, DiamondGovernanceSetup, DiamondInit, DiamondLoupeFacet, ERC20OneTimeVerificationRewardFacet, ERC20PartialBurnVotingProposalRefundFacet, ERC20PartialBurnVotingRefundFacet, ERC20TieredTimeClaimableFacet, GovernanceERC20BurnableFacet, GovernanceERC20DisabledFacet, PartialBurnVotingFacet, PartialBurnVotingProposalFacet, PluginFacet, PluginRepoFactory, PublicResolver, VerificationFacet } from "../typechain-types";

// Other
import { deployLibraries } from "./deploy_Libraries";

interface DiamondDeployedContracts {
  DiamondGovernanceSetup: DiamondGovernanceSetup;
  DiamondInit: DiamondInit;
  Facets: {
    DiamondLoupe: DiamondLoupeFacet;
    DAOReference: DAOReferenceFacet;
    Plugin: PluginFacet;
    AragonAuth: AragonAuth;
    PartialBurnVotingProposal: PartialBurnVotingProposalFacet;
    PartialBurnVoting: PartialBurnVotingFacet;
    GovernanceERC20Disabled: GovernanceERC20DisabledFacet;
    GovernanceERC20Burnable: GovernanceERC20BurnableFacet;
    ERC20PartialBurnVotingRefund: ERC20PartialBurnVotingRefundFacet;
    ERC20PartialBurnVotingProposalRefund: ERC20PartialBurnVotingProposalRefundFacet;
    ERC20TieredTimeClaimable: ERC20TieredTimeClaimableFacet;
    Verification: VerificationFacet;
    ERC20OneTimeVerificationReward: ERC20OneTimeVerificationRewardFacet;
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
  const diamondGovernanceContracts = await deployDiamondGovernance();
  const [owner] = await ethers.getSigners();

  await pluginRepoFactory.createPluginRepoWithFirstVersion(
    "my-plugin",
    diamondGovernanceContracts.DiamondGovernanceSetup.address,
    owner.address,
    toBytes("https://plopmenz.com/buildMetadata"),
    toBytes("https://plopmenz.com/releaseMetadata")
  );
  const PluginRepoAddress = await resolveENS(pluginResolver, "plugin", "my-plugin");

  const ERC20Disabled = [
    "transfer(address, uint256)", 
    "approve(address, uint256)", 
    "transferFrom(address, address, uint256)", 
    "increaseAllowance(address, uint256)", 
    "decreaseAllowance(address, uint256)", 
    "permit(address, address, uint256, uint256, uint8, bytes32, bytes32)", 
    "delegate(address)", 
    "delegateBySig(address, uint256, uint256, uint8, bytes32, bytes32)"
  ];
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
  cut.push({
    facetAddress: diamondGovernanceContracts.Facets.PartialBurnVotingProposal.address,
    action: FacetCutAction.Add,
    functionSelectors: getSelectors(diamondGovernanceContracts.Facets.PartialBurnVotingProposal)
  });
  cut.push({
    facetAddress: diamondGovernanceContracts.Facets.PartialBurnVoting.address,
    action: FacetCutAction.Add,
    functionSelectors: getSelectors(diamondGovernanceContracts.Facets.PartialBurnVoting)
  });
  cut.push({
    facetAddress: diamondGovernanceContracts.Facets.GovernanceERC20Disabled.address,
    action: FacetCutAction.Add,
    functionSelectors: getSelectors(diamondGovernanceContracts.Facets.GovernanceERC20Disabled).get(ERC20Disabled)
  });
  cut.push({
    facetAddress: diamondGovernanceContracts.Facets.GovernanceERC20Burnable.address,
    action: FacetCutAction.Add,
    functionSelectors: getSelectors(diamondGovernanceContracts.Facets.GovernanceERC20Burnable).remove(ERC20Disabled)
  });
  cut.push({
    facetAddress: diamondGovernanceContracts.Facets.ERC20PartialBurnVotingRefund.address,
    action: FacetCutAction.Add,
    functionSelectors: getSelectors(diamondGovernanceContracts.Facets.ERC20PartialBurnVotingRefund)
  });
  cut.push({
    facetAddress: diamondGovernanceContracts.Facets.ERC20PartialBurnVotingProposalRefund.address,
    action: FacetCutAction.Add,
    functionSelectors: getSelectors(diamondGovernanceContracts.Facets.ERC20PartialBurnVotingProposalRefund)
  });
  cut.push({
    facetAddress: diamondGovernanceContracts.Facets.ERC20TieredTimeClaimable.address,
    action: FacetCutAction.Add,
    functionSelectors: getSelectors(diamondGovernanceContracts.Facets.ERC20TieredTimeClaimable)
  });
  cut.push({
    facetAddress: diamondGovernanceContracts.Facets.Verification.address,
    action: FacetCutAction.Add,
    functionSelectors: getSelectors(diamondGovernanceContracts.Facets.Verification)
  });
  cut.push({
    facetAddress: diamondGovernanceContracts.Facets.ERC20OneTimeVerificationReward.address,
    action: FacetCutAction.Add,
    functionSelectors: getSelectors(diamondGovernanceContracts.Facets.ERC20OneTimeVerificationReward)
  });

  enum VotingMode { SingleVote, SinglePartialVote, MultiplePartialVote };
  const votingSettings = {
    proposalCreationCost: 1,
    partialVotingProposalInit: {
      votingSettings: {
        votingMode: VotingMode.MultiplePartialVote, //IPartialVotingFacet.VotingMode 
        supportThreshold: 1, //uint32
        minParticipation: 1, //uint32
        minDuration: 1, //uint64
        minProposerVotingPower: 1, //uint256
      }
    }
  };
  const verificationSettings = {
    verificationContractAddress: verificationContractAddress, //address
    providers: ["github", "proofofhumanity"], //string[]
    rewards: [3, 10], //uint256[]
  };
  const timeClaimSettings = {
    tiers: [1, 2, 3], //uint256[]
    rewards: [50, 100, 1], //uint256[]
    timeClaimableInit: {
      timeTillReward: 1 * days, //uint256
      maxTimeRewarded: 10 * days, //uint256
    }
  };
  const onetimeClaimSettings = {
    providers: ["github", "proofofhumanity"], //string[]
    rewards: [20, 50], //uint256[]
  };
  const constructionArgs = {
    _diamondCut: cut,
    _init: diamondGovernanceContracts.DiamondInit.address,
    _calldata: diamondGovernanceContracts.DiamondInit.interface.encodeFunctionData("init", [votingSettings, verificationSettings, timeClaimSettings, onetimeClaimSettings])
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

async function deployDiamondGovernance() : Promise<DiamondDeployedContracts> {
  const libraries = await deployLibraries();

  const DiamondGovernanceSetupContract = await ethers.getContractFactory("DiamondGovernanceSetup", {
    libraries: {
      DAOReferenceFacetInit: libraries.DAOReferenceFacetInit
    }
  });
  const DiamondGovernanceSetup = await DiamondGovernanceSetupContract.deploy();
  console.log(`DiamondGovernanceSetup deployed at ${DiamondGovernanceSetup.address}`);
  
  // Deploy DiamondInit
  // DiamondInit provides a function that is called when the diamond is upgraded to initialize state variables
  // Read about how the diamondCut function works here: https://eips.ethereum.org/EIPS/eip-2535#addingreplacingremoving-functions
  const DiamondInitContract = await ethers.getContractFactory('DiamondInit', { 
    libraries: {
      PartialBurnVotingProposalFacetInit: libraries.PartialBurnVotingProposalFacetInit,
      VerificationFacetInit: libraries.VerificationFacetInit,
      ERC20TieredTimeClaimableFacetInit: libraries.ERC20TieredTimeClaimableFacetInit,
      ERC20OneTimeVerificationRewardFacetInit: libraries.ERC20OneTimeVerificationRewardFacetInit,
    }
  });
  const DiamondInit = await DiamondInitContract.deploy();
  console.log(`DiamondInit deployed at ${DiamondInit.address}`);

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

  const PartialBurnVotingProposalFacetContract = await ethers.getContractFactory("PartialBurnVotingProposalFacet");
  const PartialBurnVotingProposalFacet = await PartialBurnVotingProposalFacetContract.deploy();
  console.log(`PartialBurnVotingProposalFacet deployed at ${PartialBurnVotingProposalFacet.address}`);

  const PartialBurnVotingFacetContract = await ethers.getContractFactory("PartialBurnVotingFacet");
  const PartialBurnVotingFacet = await PartialBurnVotingFacetContract.deploy();
  console.log(`PartialBurnVotingFacet deployed at ${PartialBurnVotingFacet.address}`);

  const GovernanceERC20DisabledFacetContract = await ethers.getContractFactory("GovernanceERC20DisabledFacet");
  const GovernanceERC20DisabledFacet = await GovernanceERC20DisabledFacetContract.deploy();
  console.log(`GovernanceERC20DisabledFacet deployed at ${GovernanceERC20DisabledFacet.address}`);

  const GovernanceERC20BurnableFacetContract = await ethers.getContractFactory("GovernanceERC20BurnableFacet");
  const GovernanceERC20BurnableFacet = await GovernanceERC20BurnableFacetContract.deploy("my-token", "TOK");
  console.log(`GovernanceERC20BurnableFacet deployed at ${GovernanceERC20BurnableFacet.address}`);

  const ERC20PartialBurnVotingRefundFacetContract = await ethers.getContractFactory("ERC20PartialBurnVotingRefundFacet");
  const ERC20PartialBurnVotingRefundFacet = await ERC20PartialBurnVotingRefundFacetContract.deploy();
  console.log(`ERC20PartialBurnVotingRefundFacet deployed at ${ERC20PartialBurnVotingRefundFacet.address}`);
  
  const ERC20PartialBurnVotingProposalRefundFacetContract = await ethers.getContractFactory("ERC20PartialBurnVotingProposalRefundFacet");
  const ERC20PartialBurnVotingProposalRefundFacet = await ERC20PartialBurnVotingProposalRefundFacetContract.deploy();
  console.log(`ERC20PartialBurnVotingProposalRefundFacet deployed at ${ERC20PartialBurnVotingProposalRefundFacet.address}`);

  const ERC20TieredTimeClaimableFacetContract = await ethers.getContractFactory("ERC20TieredTimeClaimableFacet");
  const ERC20TieredTimeClaimableFacet = await ERC20TieredTimeClaimableFacetContract.deploy();
  console.log(`ERC20TieredTimeClaimableFacet deployed at ${ERC20TieredTimeClaimableFacet.address}`);
  
  const VerificationFacetContract = await ethers.getContractFactory("VerificationFacet");
  const VerificationFacet = await VerificationFacetContract.deploy();
  console.log(`VerificationFacet deployed at ${VerificationFacet.address}`);

  const ERC20OneTimeVerificationRewardFacetContract = await ethers.getContractFactory("ERC20OneTimeVerificationRewardFacet");
  const ERC20OneTimeVerificationRewardFacet = await ERC20OneTimeVerificationRewardFacetContract.deploy();
  console.log(`ERC20OneTimeVerificationRewardFacet deployed at ${ERC20OneTimeVerificationRewardFacet.address}`);
  
  return {
    DiamondGovernanceSetup: DiamondGovernanceSetup,
    DiamondInit: DiamondInit,
    Facets: {
      DiamondLoupe: DiamondLoupeFacet,
      DAOReference: DAOReferenceFacet,
      Plugin: PluginFacet,
      AragonAuth: AragonAuth,
      PartialBurnVotingProposal: PartialBurnVotingProposalFacet,
      PartialBurnVoting: PartialBurnVotingFacet,
      GovernanceERC20Disabled: GovernanceERC20DisabledFacet,
      GovernanceERC20Burnable: GovernanceERC20BurnableFacet,
      ERC20PartialBurnVotingRefund: ERC20PartialBurnVotingRefundFacet,
      ERC20PartialBurnVotingProposalRefund: ERC20PartialBurnVotingProposalRefundFacet,
      ERC20TieredTimeClaimable: ERC20TieredTimeClaimableFacet,
      ERC20OneTimeVerificationReward: ERC20OneTimeVerificationRewardFacet,
      Verification: VerificationFacet,
    }
  };
}

export { deployDiamondGovernance, createDiamondGovernanceRepo }
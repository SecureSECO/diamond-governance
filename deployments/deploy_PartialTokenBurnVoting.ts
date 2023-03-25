// Framework
import { ethers } from "hardhat";
import fs from "fs";

// Utils
import { resolveENS } from "../utils/ensHelper";
import { minutes } from "../utils/timeUnits";
import { toBytes } from "../utils/utils";

// Types
import { PluginRepoFactory, PublicResolver } from "../typechain-types";

// Other

/**
 * Deploys the PartialTokenBurnVotingSetup contract
 * @returns The newly deployed PartialTokenBurnVotingSetup contract
 */
async function deployPartialTokenBurnVoting() {
    const PartialTokenBurnVotingSetupContract = await ethers.getContractFactory("PartialTokenBurnVotingSetup");
    const PartialTokenBurnVotingSetup = await PartialTokenBurnVotingSetupContract.deploy();
    return PartialTokenBurnVotingSetup;
}

/**
 * Deploys the PartialTokenBurnVotingSetup contract and registers it with the pluginRepoFactory
 * @param pluginRepoFactory The PluginRepoFactory to register with
 * @param pluginResolver The ENS resolver to get the plugin contract from afterwards
 * @returns The PluginSettings for installation in a DAO
 */
async function createPartialTokenBurnVotingRepo(pluginRepoFactory : PluginRepoFactory, pluginResolver : PublicResolver) {
    const buildMetadata = fs.readFileSync("./contracts/governance/PartialTokenBurnVoting/build-metadata.json", "utf8");
    const releaseMetadata = fs.readFileSync("./contracts/governance/PartialTokenBurnVoting/release-metadata.json", "utf8");
    const PartialTokenBurnVotingSetup = await deployPartialTokenBurnVoting();
    const [owner] = await ethers.getSigners();

    await pluginRepoFactory.createPluginRepoWithFirstVersion(
        "my-plugin",
        PartialTokenBurnVotingSetup.address,
        owner.address,
        toBytes("https://plopmenz.com/buildMetadata"),
        toBytes("https://plopmenz.com/releaseMetadata")
    );
    const PluginRepoAddress = await resolveENS(pluginResolver, "plugin", "my-plugin");

    const { VotingSettings, TokenSetting, MintSettings } = await defaultConstructionParams();

    const constructionFormat = JSON.parse(buildMetadata).pluginSetupABI.prepareInstallation;
    const pluginConstructionBytes = ethers.utils.defaultAbiCoder.encode(
      constructionFormat,
      [VotingSettings, TokenSetting, MintSettings]
    );

    const Tag = {
        release: 1, //uint8
        build: 1 //uint16
    };
    
    const PluginSetupRef = {
        versionTag: Tag, //PluginRepo.Tag
        pluginSetupRepo: PluginRepoAddress //PluginRepo
    };
    
    const PluginSettings = {
        pluginSetupRef: PluginSetupRef, //PluginSetupRef
        data: pluginConstructionBytes //bytes
    };

    return PluginSettings;
}

/**
 * 
 * @returns The settings to initialze the PartialTokenBurnVoting plugin with
 */
async function defaultConstructionParams() {
    const [owner] = await ethers.getSigners();

    enum PartialVotingSettings {SingleVote, SinglePartialVote, MultiplePartialVote }

    const VotingMode = {
      earlyExecution: true, //boolean
      burnTokens: true, //boolean
      partialVotingSettings: PartialVotingSettings.MultiplePartialVote //PartialVotingSettings
    };
  
    const VotingSettings = {
      votingMode: VotingMode, //VotingMode
      supportThreshold: 0, //uint32
      minParticipation: 0, //unit32
      minDuration: 60 * minutes, //uint64
      minProposerVotingPower: 0 //uint256
    };
  
    const TokenSetting = {
      name: "MyToken", //string
      symbol: "MTOK" //string
    };
  
    const MintSettings = {
      receivers: [owner.address], //address[]
      amounts: [10] //uint256[]
    };
    return { VotingSettings, TokenSetting, MintSettings };
}

export { createPartialTokenBurnVotingRepo }
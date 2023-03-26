// Framework
import { ethers } from "hardhat";

// Utils
import { resolveENS } from "../utils/ensHelper";
import { toBytes, getEvents } from "../utils/utils";

// Types

// Other
import { createPartialTokenBurnVotingRepo } from "./deploy_PartialTokenBurnVoting";
import { deployAragonFrameworkWithEns } from "./deploy_AragonOSxFramework";

/**
 * Creates a new Aragon DAO
 * This DAO has the Plugins: PartialTokenBurnVoting
 * @returns The newly created DAO
 */
async function deployAragonDAO() {
    const { daoResolver, pluginResolver, PluginRepoFactory, DAOFactory } = await deployAragonFrameworkWithEns();
    const PartialTokenBurnVotingSettings = await createPartialTokenBurnVotingRepo(PluginRepoFactory, pluginResolver);
    const DAOSettings = await GetDaoCreationParams();

    // Create DAO
    const tx = await DAOFactory.createDao(DAOSettings, [PartialTokenBurnVotingSettings]);
    const receipt = await tx.wait();
    
    // Retrieve plugin address from DAO creation log
    const PluginSetupProcessorContract = await ethers.getContractFactory("PluginSetupProcessor");
    const pluginAddresses = getEvents(PluginSetupProcessorContract, "InstallationApplied", receipt).map((log : any) => log.args.plugin);

    // Retrieve DAO address with ENS
    const DAOAddress = await resolveENS(daoResolver, "dao", "my-dao");
    const DAOConctract = await ethers.getContractFactory("DAO");
    const DAO = await DAOConctract.attach(DAOAddress);

    // Link plugin addresses to Contracts
    const PartialTokenBurnVotingContract = await ethers.getContractFactory("PartialTokenBurnVoting");
    const PartialTokenBurnVoting = await PartialTokenBurnVotingContract.attach(pluginAddresses[0]);
    return { DAO, PartialTokenBurnVoting };
}

async function GetDaoCreationParams() {
  const DAOSettings = {
    trustedForwarder: ethers.constants.AddressZero, //address
    daoURI: "https://plopmenz.com", //string
    subdomain: "my-dao", //string
    metadata: toBytes("https://plopmenz.com/daoMetadata") //bytes
  };

  return DAOSettings;
}

export { deployAragonDAO }
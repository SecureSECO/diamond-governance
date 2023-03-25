// Framework
import { ethers } from "hardhat";

// Utils
import { resolveENS } from "../utils/ensHelper";
import { toBytes } from "../utils/utils";

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
    await DAOFactory.createDao(DAOSettings, [PartialTokenBurnVotingSettings]);
    const DAOAddress = await resolveENS(daoResolver, "dao", "my-dao");

    const DAOConctract = await ethers.getContractFactory("DAO");
    const DAO = await DAOConctract.attach(DAOAddress);
    return DAO;
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
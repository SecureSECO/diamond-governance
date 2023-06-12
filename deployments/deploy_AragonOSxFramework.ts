/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  *
  * This source code is licensed under the MIT license found in the
  * LICENSE file in the root directory of this source tree.
  */

// Framework
import { ethers, upgrades } from "hardhat";

// Utils
import { toEnsNode } from "../utils/ensHelper";

// Types
import { DAO, DAORegistry, ENSRegistry, ENSSubdomainRegistrar, PluginRepoRegistry } from "../typechain-types";
import { ENSFrameworkContracts, AragonOSxFrameworkContracts } from "./deploymentTypes";

// Other
import { deployENS, deployResolver } from "./deploy_ENS";

async function setupENS() : Promise<ENSFrameworkContracts> {
    const ens = await deployENS();
    const [owner] = await ethers.getSigners();

    const daoResolver = await deployResolver(ens, owner.address, "dao");    
    const pluginResolver = await deployResolver(ens, owner.address, "plugin");

    return { ens, daoResolver, pluginResolver };
}

/**
 * Grants permissions to an address in a DAO
 * @param dao The DAO that the permissions will be granted in
 * @param where The address of the contract that the permissions will be granted to
 * @param who The address of the account that the permissions will be granted to
 * @param permissionId The ID of the permission that will be granted
 */
async function grant(dao : DAO, where : any, who : any, permissionId : string) {
    await dao.grant(where.address, who.address, ethers.utils.keccak256(ethers.utils.toUtf8Bytes(permissionId)));
}

/**
 * Deploys the AragonOSxFramework contracts
 * @param ens Deployed ENSRegistry
 * @returns Deployed AragonOSxFramework contracts
 */
export async function deployAragonFramework(ens : ENSRegistry) : Promise<AragonOSxFrameworkContracts> {
    const [owner] = await ethers.getSigners();

    // ManagingDAO: "0x005098056a837c2c4F99C7eCeE976F8D90bdFFF8", https://github.com/aragon/osx/blob/develop/packages/contracts/src/core/dao/DAO.sol
    const DAOContract = await ethers.getContractFactory("DAO");
    const ManagingDAO = await upgrades.deployProxy(
        DAOContract,
        ["0x", owner.address, ethers.constants.AddressZero, '0x'],
        { unsafeAllow: ['constructor'] }
    ) as DAO;

    // DAO_ENSSubdomainRegistrar: "0xCe0B4124dea6105bfB85fB4461c4D39f360E9ef3", https://github.com/aragon/osx/blob/develop/packages/contracts/src/framework/utils/ens/ENSSubdomainRegistrar.sol
    const DAO_ENSSubdomainRegistrarContract = await ethers.getContractFactory("ENSSubdomainRegistrar");
    const DAO_ENSSubdomainRegistrar = await upgrades.deployProxy(
        DAO_ENSSubdomainRegistrarContract, 
        [ManagingDAO.address, ens.address, toEnsNode("dao")],
        { unsafeAllow: ['constructor'] }
    );
    await ens.setApprovalForAll(
        DAO_ENSSubdomainRegistrar.address,
        true
    );

    // Plugin_ENSSubdomainRegistrar: "0x08633901DdF9cD8e2DC3a073594d0A7DaD6f3f57", https://github.com/aragon/osx/blob/develop/packages/contracts/src/framework/utils/ens/ENSSubdomainRegistrar.sol
    const Plugin_ENSSubdomainRegistrarContract = await ethers.getContractFactory("ENSSubdomainRegistrar");
    const Plugin_ENSSubdomainRegistrar = await upgrades.deployProxy(
        Plugin_ENSSubdomainRegistrarContract, 
        [ManagingDAO.address, ens.address, toEnsNode("plugin")],
        { unsafeAllow: ['constructor'] }
    );
    await ens.setApprovalForAll(
        Plugin_ENSSubdomainRegistrar.address,
        true
    );

    // DAORegistry: "0xC24188a73dc09aA7C721f96Ad8857B469C01dC9f", https://github.com/aragon/osx/blob/develop/packages/contracts/src/framework/dao/DAORegistry.sol
    const DAORegistryContract = await ethers.getContractFactory("DAORegistry");
    const DAORegistry = await upgrades.deployProxy(
        DAORegistryContract, 
        [ManagingDAO.address, DAO_ENSSubdomainRegistrar.address],
        { unsafeAllow: ['constructor'] }
    );
    
    // PluginRepoRegistry: "0xddCc39a2a0047Eb47EdF94180452cbaB14d426EF", https://github.com/aragon/osx/blob/develop/packages/contracts/src/framework/plugin/repo/PluginRepoRegistry.sol
    const PluginRepoRegistryContract = await ethers.getContractFactory("PluginRepoRegistry");
    const PluginRepoRegistry = await upgrades.deployProxy(
        PluginRepoRegistryContract, 
        [ManagingDAO.address, Plugin_ENSSubdomainRegistrar.address],
        { unsafeAllow: ['constructor'] }
    );

    // PluginRepoFactory: "0x96E54098317631641703404C06A5afAD89da7373", https://github.com/aragon/osx/blob/develop/packages/contracts/src/framework/plugin/repo/PluginRepoFactory.sol
    const PluginRepoFactoryContract = await ethers.getContractFactory("PluginRepoFactory");
    const PluginRepoFactory = await PluginRepoFactoryContract.deploy(PluginRepoRegistry.address);

    // PluginSetupProcessor: "0xE978942c691e43f65c1B7c7F8f1dc8cDF061B13f", https://github.com/aragon/osx/blob/develop/packages/contracts/src/framework/plugin/setup/PluginSetupProcessor.sol
    const PluginSetupProcessorContract = await ethers.getContractFactory("PluginSetupProcessor");
    const PluginSetupProcessor = await PluginSetupProcessorContract.deploy(PluginRepoRegistry.address);

    // DAOFactory: "0xA03C2182af8eC460D498108C92E8638a580b94d4", https://github.com/aragon/osx/blob/develop/packages/contracts/src/framework/dao/DAOFactory.sol
    const DAOFactoryContract = await ethers.getContractFactory("DAOFactory");
    const DAOFactory = await DAOFactoryContract.deploy(DAORegistry.address, PluginSetupProcessor.address);

    // Permissions DAO
    const DAO_PERMISSIONS = [
        'ROOT_PERMISSION',
        'UPGRADE_DAO_PERMISSION',
        'SET_SIGNATURE_VALIDATOR_PERMISSION',
        'SET_TRUSTED_FORWARDER_PERMISSION',
        'SET_METADATA_PERMISSION',
        'REGISTER_STANDARD_CALLBACK_PERMISSION',
    ];
    await DAO_PERMISSIONS.forEach(async permission => await grant(ManagingDAO, ManagingDAO, ManagingDAO, permission));

    // Permissions ENS
    await grant(ManagingDAO, DAO_ENSSubdomainRegistrar, DAORegistry, "REGISTER_ENS_SUBDOMAIN_PERMISSION");
    await grant(ManagingDAO, Plugin_ENSSubdomainRegistrar, PluginRepoRegistry, "REGISTER_ENS_SUBDOMAIN_PERMISSION");
    await grant(ManagingDAO, DAO_ENSSubdomainRegistrar, ManagingDAO, "UPGRADE_REGISTRAR_PERMISSION");
    await grant(ManagingDAO, Plugin_ENSSubdomainRegistrar, ManagingDAO, "UPGRADE_REGISTRAR_PERMISSION");

    // Permissions DAO registry
    await grant(ManagingDAO, DAORegistry, DAOFactory, "REGISTER_DAO_PERMISSION");
    await grant(ManagingDAO, DAORegistry, ManagingDAO, "UPGRADE_REGISTRY_PERMISSION");

    // Permissions plugin registry
    await grant(ManagingDAO, PluginRepoRegistry, PluginRepoFactory, "REGISTER_PLUGIN_REPO_PERMISSION");
    await grant(ManagingDAO, PluginRepoRegistry, ManagingDAO, "UPGRADE_REGISTRY_PERMISSION");

    return { 
        ManagingDAO: ManagingDAO, 
        DAO_ENSSubdomainRegistrar: DAO_ENSSubdomainRegistrar as ENSSubdomainRegistrar, 
        Plugin_ENSSubdomainRegistrar: Plugin_ENSSubdomainRegistrar as ENSSubdomainRegistrar, 
        DAORegistry: DAORegistry as DAORegistry, 
        PluginRepoRegistry: PluginRepoRegistry as PluginRepoRegistry, 
        PluginRepoFactory: PluginRepoFactory, 
        PluginSetupProcessor: PluginSetupProcessor, 
        DAOFactory: DAOFactory,
    };
}

/**
 * Deploys the AragonOS framework with the ENS framework
 * @returns The deployed contracts for the AragonOS framework and the ENS framework
 */
export async function deployAragonFrameworkWithEns() {
    const ensFramework = await setupENS();
    const aragonOSxFramework = await deployAragonFramework(ensFramework.ens);

    return { ensFramework, aragonOSxFramework };
}
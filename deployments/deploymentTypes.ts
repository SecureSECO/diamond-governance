import { DAO, DAOFactory, DAORegistry, ENS, ENSSubdomainRegistrar, PluginRepoFactory, PluginRepoRegistry, PluginSetupProcessor, PublicResolver } from "../typechain-types";

export interface AragonOSxFrameworkContracts {
    ManagingDAO : DAO;
    DAO_ENSSubdomainRegistrar: ENSSubdomainRegistrar;
    Plugin_ENSSubdomainRegistrar: ENSSubdomainRegistrar;
    DAORegistry: DAORegistry;
    PluginRepoRegistry: PluginRepoRegistry; 
    PluginRepoFactory : PluginRepoFactory;
    PluginSetupProcessor: PluginSetupProcessor;
    DAOFactory: DAOFactory;
}

export interface ENSFrameworkContracts {
    ens: ENS;
    daoResolver: PublicResolver;
    pluginResolver: PublicResolver;
}
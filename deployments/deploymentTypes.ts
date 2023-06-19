/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  *
  * This source code is licensed under the MIT license found in the
  * LICENSE file in the root directory of this source tree.
  */
 
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
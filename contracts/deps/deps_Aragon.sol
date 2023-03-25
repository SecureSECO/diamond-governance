// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.8.17;

import {DAO} from "@aragon/osx/core/dao/DAO.sol";

import {DAOFactory} from "@aragon/osx/framework/dao/DAOFactory.sol";
import {DAORegistry} from "@aragon/osx/framework/dao/DAORegistry.sol";

import {PluginRepoFactory} from "@aragon/osx/framework/plugin/repo/PluginRepoFactory.sol";
import {PluginRepoRegistry} from "@aragon/osx/framework/plugin/repo/PluginRepoRegistry.sol";

import {PluginSetupProcessor} from "@aragon/osx/framework/plugin/setup/PluginSetupProcessor.sol";

import {ENSSubdomainRegistrar} from "@aragon/osx/framework/utils/ens/ENSSubdomainRegistrar.sol";
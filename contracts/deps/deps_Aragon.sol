// SPDX-License-Identifier: AGPL-3.0-or-later
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  */


pragma solidity ^0.8.0;

import { DAO }  from "@aragon/osx/core/dao/DAO.sol";

import { DAOFactory } from "@aragon/osx/framework/dao/DAOFactory.sol";
import { DAORegistry } from "@aragon/osx/framework/dao/DAORegistry.sol";

import { PluginRepoFactory } from "@aragon/osx/framework/plugin/repo/PluginRepoFactory.sol";
import { PluginRepoRegistry } from "@aragon/osx/framework/plugin/repo/PluginRepoRegistry.sol";

import { PluginSetupProcessor } from "@aragon/osx/framework/plugin/setup/PluginSetupProcessor.sol";

import { ENSSubdomainRegistrar } from "@aragon/osx/framework/utils/ens/ENSSubdomainRegistrar.sol";
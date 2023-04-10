// SPDX-License-Identifier: MIT
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  */

pragma solidity ^0.8.0;

import { IPlugin } from "@aragon/osx/core/plugin/IPlugin.sol";

contract PluginFacet is IPlugin {
    /// @inheritdoc IPlugin
    function pluginType() external pure override returns (PluginType) {
        return PluginType.Constructable;
    }
}
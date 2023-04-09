// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IPlugin } from "@aragon/osx/core/plugin/IPlugin.sol";

contract PluginFacet is IPlugin {
    /// @inheritdoc IPlugin
    function pluginType() external pure override returns (PluginType) {
        return PluginType.Constructable;
    }
}
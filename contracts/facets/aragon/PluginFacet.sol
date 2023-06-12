// SPDX-License-Identifier: MIT
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  */

pragma solidity ^0.8.0;

import { IPlugin } from "@aragon/osx/core/plugin/IPlugin.sol";
import { IFacet } from "../IFacet.sol";

contract PluginFacet is IPlugin, IFacet {
    /// @inheritdoc IPlugin
    function pluginType() external pure override returns (PluginType) {
        return PluginType.Constructable;
    }

    /// @inheritdoc IFacet
    function init(bytes memory/* _initParams*/) public virtual override {
        __PluginFacet_init();
    }

    function __PluginFacet_init() public virtual {
        registerInterface(type(IPlugin).interfaceId);
    }

    /// @inheritdoc IFacet
    function deinit() public virtual override {
        unregisterInterface(type(IPlugin).interfaceId);
        super.deinit();
    }
}
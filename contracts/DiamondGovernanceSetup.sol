// SPDX-License-Identifier: AGPL-3.0-or-later
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  */

pragma solidity ^0.8.0;

import { PermissionLib } from "@aragon/osx/core/permission/PermissionLib.sol";
import { PluginSetup } from "@aragon/osx/framework/plugin/setup/PluginSetup.sol";
import { DAO } from "@aragon/osx/core/dao/DAO.sol";

import { DiamondGovernanceAragon, IDiamondCut } from "./DiamondGovernanceAragon.sol";

contract DiamondGovernanceSetup is PluginSetup {
  function prepareInstallation(
    address _dao,
    bytes memory _data
  ) external returns (address plugin, PreparedSetupData memory preparedSetupData) {
    // Decode `_data` to extract the params needed for deploying and initializing `DiamondGovernance` plugin
    (IDiamondCut.FacetCut[] memory _diamondCut) = abi.decode(_data, (IDiamondCut.FacetCut[]));
    plugin = address(new DiamondGovernanceAragon(DAO(payable(_dao)), _diamondCut));

    // Prepare permissions
    PermissionLib.MultiTargetPermission[]
        memory permissions = new PermissionLib.MultiTargetPermission[](1);

    // Set plugin permissions to be granted.
    // Grant the list of prmissions of the plugin to the DAO.

    // Grant `EXECUTE_PERMISSION` of the DAO to the plugin.
    permissions[0] = PermissionLib.MultiTargetPermission(
        PermissionLib.Operation.Grant,
        _dao,
        plugin,
        PermissionLib.NO_CONDITION,
        DAO(payable(_dao)).EXECUTE_PERMISSION_ID()
    );

    preparedSetupData.permissions = permissions;
  }

  function prepareUninstallation(
    address _dao,
    SetupPayload calldata _payload
  ) external view returns (PermissionLib.MultiTargetPermission[] memory permissions) {
      permissions = new PermissionLib.MultiTargetPermission[](1);

      // Revoke `EXECUTE_PERMISSION` of the DAO to the plugin.
      permissions[0] = PermissionLib.MultiTargetPermission(
          PermissionLib.Operation.Revoke,
          _dao,
          _payload.plugin,
          PermissionLib.NO_CONDITION,
          DAO(payable(_dao)).EXECUTE_PERMISSION_ID()
      );
  }

  function implementation() external view returns (address) {}
}
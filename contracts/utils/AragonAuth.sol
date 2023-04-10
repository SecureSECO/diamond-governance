// SPDX-License-Identifier: MIT
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  */

pragma solidity ^0.8.0;

import { _auth } from "@aragon/osx/core/utils/auth.sol";

import { DAOReferenceFacet } from "../facets/aragon/DAOReferenceFacet.sol";

abstract contract AragonAuth {
    /// @notice A modifier to make functions on inheriting contracts authorized. Permissions to call the function are checked through the associated DAO's permission manager.
    /// @param _permissionId The permission identifier required to call the method this modifier is applied to.
    modifier auth(bytes32 _permissionId) {
        if (msg.sender != address(this)) {
            _auth(DAOReferenceFacet(address(this)).dao(), address(this), msg.sender, _permissionId, msg.data);
        }
        _;
    }
}
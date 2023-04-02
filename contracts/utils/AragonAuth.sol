// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { _auth, IDAO } from "@aragon/osx/core/utils/auth.sol";

abstract contract AragonAuth {
    /// @notice A modifier to make functions on inheriting contracts authorized. Permissions to call the function are checked through the associated DAO's permission manager.
    /// @param _permissionId The permission identifier required to call the method this modifier is applied to.
    modifier auth(bytes32 _permissionId) {
        if (msg.sender != address(this)) {
            _auth(IDAO(address(this)), address(this), msg.sender, _permissionId, msg.data);
        }
        _;
    }
}
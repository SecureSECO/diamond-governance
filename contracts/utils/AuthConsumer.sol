// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IAuthProvider } from "./auth-providers/IAuthProvider.sol";

abstract contract AuthConsumer {
    /// @notice A modifier to make functions on inheriting contracts authorized. Permissions to call the function are checked through the associated DAO's permission manager.
    /// @param _permissionId The permission identifier required to call the method this modifier is applied to.
    modifier auth(bytes32 _permissionId) {
        if (msg.sender != address(this)) {
            IAuthProvider(address(this)).auth(_permissionId);
        }
        _;
    }
}
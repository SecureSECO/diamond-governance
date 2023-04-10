// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { _auth } from "@aragon/osx/core/utils/auth.sol";

import { IAuthProvider } from "./IAuthProvider.sol";
import { DAOReferenceFacet } from "../../facets/aragon/DAOReferenceFacet.sol";

contract AragonAuth is IAuthProvider {
    /// @inheritdoc IAuthProvider
    function auth(bytes32 _permissionId) external virtual override {
        _auth(DAOReferenceFacet(address(this)).dao(), address(this), msg.sender, _permissionId, msg.data);
    }
}
// SPDX-License-Identifier: MIT
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  *
  * This source code is licensed under the MIT license found in the
  * LICENSE file in the root directory of this source tree.
  */
 
pragma solidity ^0.8.0;

import { _auth } from "@aragon/osx/core/utils/auth.sol";

import { IAuthProvider } from "./IAuthProvider.sol";
import { DAOReferenceFacet } from "../../facets/aragon/DAOReferenceFacet.sol";
import { IFacet } from "../../facets/IFacet.sol";

contract AragonAuthFacet is IAuthProvider, IFacet {
    /// @inheritdoc IAuthProvider
    function auth(bytes32 _permissionId) external virtual override {
        _auth(DAOReferenceFacet(address(this)).dao(), address(this), msg.sender, _permissionId, msg.data);
    }
}
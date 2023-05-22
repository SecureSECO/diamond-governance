// SPDX-License-Identifier: MIT
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  *
  * This source code is licensed under the MIT license found in the
  * LICENSE file in the root directory of this source tree.
  */
 
pragma solidity ^0.8.0;

import { ERC20DisabledFacet } from "./ERC20DisabledFacet.sol";
import { IERC20Permit } from "@openzeppelin/contracts/token/ERC20/extensions/draft-IERC20Permit.sol";
import { IFacet } from "../../../../IFacet.sol";

contract ERC20PermitDisabledFacet is ERC20DisabledFacet, IERC20Permit {
    /// @inheritdoc IERC20Permit
    function permit(
        address/* owner*/,
        address/* spender*/,
        uint256/* value*/,
        uint256/* deadline*/,
        uint8/* v*/,
        bytes32/* r*/,
        bytes32/* s*/
    ) external pure override {
        revert("Disabled");
    }

    /// @inheritdoc IERC20Permit
    function nonces(address/* owner*/) external pure override returns (uint256) {
        revert("Disabled");
    }

    /// @inheritdoc IERC20Permit
    function DOMAIN_SEPARATOR() external pure override returns (bytes32) {
        revert("Disabled");
    }
}
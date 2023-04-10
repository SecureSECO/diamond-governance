// SPDX-License-Identifier: MIT
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  *
  * This source code is licensed under the MIT license found in the
  * LICENSE file in the root directory of this source tree.
  */
 
pragma solidity ^0.8.0;

import { ERC20PermitDisabledFacet } from "./ERC20PermitDisabledFacet.sol";
import { IERC5805, IERC6372, IVotes } from "../../../../../additional-contracts/IERC5805.sol";
import { ERC20VotesFacet } from "../ERC20VotesFacet.sol";

contract ERC20VotesDisabledFacet is ERC20PermitDisabledFacet, IERC5805 {
    /// @inheritdoc IERC6372
    function clock() external pure override returns (uint48) {
        revert("Disabled");
    }

    /// @inheritdoc IERC6372
    function CLOCK_MODE() external pure override returns (string memory) {
        revert("Disabled");
    }

    function checkpoints(address/* account*/, uint32/* pos*/) external pure returns (ERC20VotesFacet.Checkpoint memory) {
        revert("Disabled");
    }

    function numCheckpoints(address/* account*/) external pure returns (uint32) {
        revert("Disabled");
    }

    /// @inheritdoc IVotes
    function delegates(address/* account*/) external pure override returns (address) {
        revert("Disabled");
    }

    /// @inheritdoc IVotes
    function getVotes(address/* account*/) external pure override returns (uint256) {
        revert("Disabled");
    }

    /// @inheritdoc IVotes
    function getPastVotes(address/* account*/, uint256/* timepoint*/) external pure override returns (uint256) {
        revert("Disabled");
    }

    /// @inheritdoc IVotes
    function getPastTotalSupply(uint256/* timepoint*/) external pure override returns (uint256) {
        revert("Disabled");
    }

    /// @inheritdoc IVotes
    function delegate(address/* delegatee*/) external pure override {
        revert("Disabled");
    }
    
    /// @inheritdoc IVotes
    function delegateBySig(
        address/* delegatee*/,
        uint256/* nonce*/,
        uint256/* expiry*/,
        uint8/* v*/,
        bytes32/* r*/,
        bytes32/* s*/
    ) public virtual override {
        revert("Disabled");
    }
}
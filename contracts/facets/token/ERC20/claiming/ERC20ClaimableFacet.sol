// SPDX-License-Identifier: MIT
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  */

pragma solidity ^0.8.0;

import { IMintableGovernanceStructure } from "../../../governance/structure/voting-power/IMintableGovernanceStructure.sol";

abstract contract ERC20ClaimableFacet {
    function tokensClaimable(address _claimer) public view virtual returns (uint256 amount);

    function _afterClaim(address _claimer) internal virtual;

    function claim() external virtual {
        IMintableGovernanceStructure(address(this)).mintVotingPower(msg.sender, 0, tokensClaimable(msg.sender));
        _afterClaim(msg.sender);
    }
}
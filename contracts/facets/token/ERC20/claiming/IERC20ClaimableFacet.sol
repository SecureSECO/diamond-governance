// SPDX-License-Identifier: MIT
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  */

pragma solidity ^0.8.0;

import { IMintableGovernanceStructure } from "../../../governance/structure/voting-power/IMintableGovernanceStructure.sol";
import { IFacet } from "../../../IFacet.sol";

abstract contract IERC20ClaimableFacet is IFacet {
    function _tokensClaimable(address _claimer) internal view virtual returns (uint256 amount);

    function _afterClaim(address _claimer) internal virtual;

    function _claim(address _claimer) internal virtual {
        IMintableGovernanceStructure(address(this)).mintVotingPower(_claimer, 0, _tokensClaimable(_claimer));
        _afterClaim(_claimer);
    }
}
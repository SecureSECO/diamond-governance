// SPDX-License-Identifier: MIT
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  */

pragma solidity ^0.8.0;

import { IMintableGovernanceStructure } from "../../../governance/structure/voting-power/IMintableGovernanceStructure.sol";
import { IFacet } from "../../../IFacet.sol";

/**
 * @title IERC20ClaimableFacet
 * @author Utrecht University
 * @notice This interface is a base for claimable facets, where there is a certain amount of tokens claimable and an action to change that amount somehow after claim.
 * @dev This will not work with all claimable facets, but is nice base to not duplicate the claim code everywhere
 * There are also no exposed functions, as this would give function collision when adding all claimable facets to a single diamond.
 */
abstract contract IERC20ClaimableFacet is IFacet {
    function _tokensClaimable(address _claimer) internal view virtual returns (uint256 amount);

    function _afterClaim(address _claimer) internal virtual;

    function _claim(address _claimer) internal virtual {
        IMintableGovernanceStructure(address(this)).mintVotingPower(_claimer, 0, _tokensClaimable(_claimer));
        _afterClaim(_claimer);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IMintableGovernanceStructure } from "../../../governance/structure/voting-power/IMintableGovernanceStructure.sol";

abstract contract ERC20ClaimableFacet {
    function _tokensClaimable(address _claimer) internal view virtual returns (uint256 amount);

    function _afterClaim(address _claimer) internal virtual;

    function _claim(address _claimer) internal virtual {
        IMintableGovernanceStructure(address(this)).mintVotingPower(_claimer, 0, _tokensClaimable(_claimer));
        _afterClaim(_claimer);
    }
}
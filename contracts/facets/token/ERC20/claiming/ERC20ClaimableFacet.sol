// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IMintableGovernanceStructure } from "../../../governance/structure/IMintableGovernanceStructure.sol";

contract ERC20ClaimableFacet {
    function tokensClaimable(address _wallet) public view virtual returns (uint256 amount) {
        // Temp mock
        require(_wallet != address(0), "Uhhh");
        return 1;
    }

    function claim() external virtual {
        IMintableGovernanceStructure(address(this)).mintVotingPower(msg.sender, 0, tokensClaimable(msg.sender));
        // set claimable to zero for this wallet
    }
}
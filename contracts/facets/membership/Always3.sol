// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { ITieredMembershipStructure } from "../../facets/governance/structure/membership/ITieredMembershipStructure.sol";

// TEMP MOCK for verifiction
contract Always3 is ITieredMembershipStructure {
    /// @inheritdoc ITieredMembershipStructure
    function getMembers() external view virtual override returns (address[] memory members) {
        
    }

    /// @inheritdoc ITieredMembershipStructure
    function getTier(address/* _account*/) public view virtual override returns (uint256) {
        return 3;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IMembershipExtended } from "./IMembershipExtended.sol";

abstract contract ITieredMembershipStructure is IMembershipExtended {
    /// @inheritdoc IMembershipExtended
    function isMember(address _account) external view virtual override returns (bool) {
        return getTier(_account) > 0;
    }

    /// @inheritdoc IMembershipExtended
    function getMembers() external view virtual override returns (address[] memory);

    function getTier(address _account) public view virtual returns (uint256);
}
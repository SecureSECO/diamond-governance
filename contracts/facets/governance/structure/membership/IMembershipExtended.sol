// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IMembership } from "@aragon/osx/core/plugin/membership/IMembership.sol";

interface IMembershipExtended is IMembership {
    /// @inheritdoc IMembership
    function isMember(address _account) external view override returns (bool);

    /// Returns whether an account was a member at a given timestamp
    function isMemberAt(address _account, uint256 _timestamp) external view returns (bool);

    /// Returns all accounts that were a member at some point
    /// @dev Can be used to loop over all members, loop over this array with filter isMember
    function getMembers() external view returns (address[] memory);
}
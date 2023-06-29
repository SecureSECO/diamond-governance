// SPDX-License-Identifier: MIT
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  */

pragma solidity ^0.8.0;

import { IMembership } from "@aragon/osx/core/plugin/membership/IMembership.sol";

/**
 * @title IDAOReferenceFacet
 * @author Utrecht University
 * @notice This interface is an extension upon Aragons IMembership.
 * It allows to query is a wallet was a member at a certain timestamp.
 * It allows to get a list of all wallets that were a member at some point.
 */
interface IMembershipExtended is IMembership {
    /// @inheritdoc IMembership
    function isMember(address _account) external view override returns (bool);

    /// Returns whether an account was a member at a given timestamp
    function isMemberAt(address _account, uint256 _blockNumber) external view returns (bool);

    /// Returns all accounts that were a member at some point
    /// @dev Can be used to loop over all members, loop over this array with filter isMember
    function getMembers() external view returns (address[] memory);
}
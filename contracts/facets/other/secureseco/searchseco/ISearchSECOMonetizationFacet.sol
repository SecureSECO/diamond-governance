// SPDX-License-Identifier: AGPL-3.0-or-later
/**
 * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
 * © Copyright Utrecht University (Department of Information and Computing Sciences)
 */

pragma solidity ^0.8.0;

/// @title ISearchSECORewardingFacet
/// @author Utrecht University - 2023
/// @notice The interface of the rewarding (miners) plugin.
abstract contract ISearchSECOMonetizationFacet {
    /// @notice This function is used to pay for hashes. The user builds a credit of hashes.
    /// @param _amount Number of hashes the user wants to pay for
    function payForHashes(uint _amount, string memory _uniqueId) external virtual;

    /// @notice Updates the cost of a hash (in the context of SearchSECO)
    /// @param _newCost The new cost of a hash
    function updateHashCost(uint _newCost) external virtual;

    /// @notice Retrieve the current cost of a hash
    /// @return uint The current hashcost
    function getHashCost() external view virtual returns (uint);
}

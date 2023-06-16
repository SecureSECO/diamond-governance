// SPDX-License-Identifier: AGPL-3.0-or-later
/**
 * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
 * © Copyright Utrecht University (Department of Information and Computing Sciences)
 */

pragma solidity ^0.8.0;

/**
 * @title ISearchSECOMonetizationFacet
 * @author Utrecht University
 * @notice This interface allows the monetization of SearchSECO.
 * You can query about query cost and pay for a query in the form of hashes.
 */
interface ISearchSECOMonetizationFacet {
    /// @notice This function is used to pay for hashes. The user builds a credit of hashes.
    /// @param _amount Number of hashes the user wants to pay for
    function payForHashes(uint _amount, string memory _uniqueId) external;

    /// @notice Retrieve the current cost of a hash
    /// @return uint The current hashcost
    function getHashCost() external view returns (uint);

    /// @notice Updates the cost of a hash (in the context of SearchSECO)
    /// @param _hashCost The new cost of a hash
    function setHashCost(uint _hashCost) external;

    /// @notice Retrieve the current treasury ratio. This is the percentage of the hashcost that goes to the treasury.
    /// @return uint32 The current treasury ratio
    function getQueryMiningRewardPoolRatio() external view returns (uint32);

    /// @notice Updates the treasury ratio
    /// @param _queryMiningRewardPoolRatio The new treasury ratio
    function setQueryMiningRewardPoolRatio(uint32 _queryMiningRewardPoolRatio) external;
}

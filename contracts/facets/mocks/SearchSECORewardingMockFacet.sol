// SPDX-License-Identifier: MIT
/**
 * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
 * © Copyright Utrecht University (Department of Information and Computing Sciences)
 */

pragma solidity ^0.8.0;

import {SearchSECORewardingFacet} from "../searchseco-rewarding/SearchSECORewardingFacet.sol";

contract SearchSECORewardingMockFacet {
    /// Mock function that sets the hash reward
    /// @notice Sets the hash reward (REP)
    /// @param _hashReward The new hash reward
    function _setHashReward(uint _hashReward) public {
        SearchSECORewardingFacet searchSECORewardingFacet = SearchSECORewardingFacet(
                address(this)
            );
        searchSECORewardingFacet.setHashReward(_hashReward);
    }

    /// @notice Rewards the user for submitting new hashes
    /// @param _toReward The address of the user to reward
    /// @param _hashCount The number of new hashes the user has submitted
    /// @param _nonce A nonce
    /// @param _repFrac The fraction (0 - 1_000_000) of the reward that should be paid in REP. The rest is paid in monetary tokens
    /// @param _proof The proof that the user received from the server
    function reward(
        address _toReward,
        uint _hashCount,
        uint _nonce,
        uint _repFrac,
        bytes calldata _proof
    ) public {
        SearchSECORewardingFacet searchSECORewardingFacet = SearchSECORewardingFacet(
                address(this)
            );
        searchSECORewardingFacet.reward(
            _toReward,
            _hashCount,
            _nonce,
            _repFrac,
            _proof
        );
    }
}

// SPDX-License-Identifier: AGPL-3.0-or-later
/**
 * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
 * © Copyright Utrecht University (Department of Information and Computing Sciences)
 */

pragma solidity ^0.8.0;

/// @title ISearchSECORewardingFacet
/// @author Utrecht University - 2023
/// @notice The interface of the rewarding (miners) plugin.
interface ISearchSECORewardingFacet {
    /// @notice Rewards the user for submitting new hashes
    /// @param _toReward The address of the user to reward
    /// @param _hashCount The number of new hashes the user has submitted
    /// @param _nonce A nonce
    /// @param _proof The proof that the user received from the server
    function reward(
        address _toReward,
        uint _hashCount,
        uint _nonce,
        uint _repFrac,
        bytes calldata _proof
    ) external;

    /// @notice Returns the hash count for a given user
    /// @param _user The address of the user
    /// @return The hash count
    function getHashCount(address _user) external view returns (uint);

    function getHashReward() external view returns (uint);

    /// @notice Sets the hash reward (REP)
    /// @param _hashReward The new hash reward
    function setHashReward(uint _hashReward) external;

    /// @notice Returns the signer used for signature verification
    /// @return address signer
    function getRewardingSigner() external view returns (address);

    /// @notice Sets the signer used for signature verification
    /// @param _rewardingSigner The new signer
    function setRewardingSigner(address _rewardingSigner) external;
}

// SPDX-License-Identifier: MIT
/**
 * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
 * © Copyright Utrecht University (Department of Information and Computing Sciences)
 */

pragma solidity ^0.8.0;

library LibVerificationRewardPoolStorage {
    bytes32 constant VERIFICATION_REWARD_POOL_STORAGE_POSITION =
        keccak256("verification.reward.pool.storage.position");

    struct Storage {
        /// @notice Represents the pool for verification rewards.
        uint256 verificationRewardPool;
    }

    function getStorage() internal pure returns (Storage storage ds) {
        bytes32 position = VERIFICATION_REWARD_POOL_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}

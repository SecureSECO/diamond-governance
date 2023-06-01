// SPDX-License-Identifier: MIT
/**
 * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
 * © Copyright Utrecht University (Department of Information and Computing Sciences)
 */

pragma solidity ^0.8.0;

library LibMiningRewardStorage {
    bytes32 constant MINING_REWARD_PIGGY_BANK_STORAGE_POSITION =
        keccak256("mining.reward.piggy.bank.storage.position");

    struct Storage {
        /// @notice Represents the piggy bank for rewarding the miners.
        uint256 piggyBank;
    }

    function getStorage() internal pure returns (Storage storage ds) {
        bytes32 position = MINING_REWARD_PIGGY_BANK_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}

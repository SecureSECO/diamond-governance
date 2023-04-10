// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library LibERC20OneTimeRewardStorage {
    bytes32 constant ONE_TIME_REWARD_CLAIM_STORAGE_POSITION =
        keccak256("onetime.claim.diamond.storage.position");

    struct Storage {
        uint256 reward;
        mapping(address => uint256) hasClaimed;
    }

    function getStorage() internal pure returns (Storage storage ds) {
        bytes32 position = ONE_TIME_REWARD_CLAIM_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
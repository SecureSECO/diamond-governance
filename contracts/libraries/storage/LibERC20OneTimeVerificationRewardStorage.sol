// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library LibERC20OneTimeVerificationRewardStorage {
    bytes32 constant ONE_TIME_VERIFICATION_REWARD_CLAIM_STORAGE_POSITION =
        keccak256("verification.onetime.claim.diamond.storage.position");

    struct Storage {
        mapping(string => bool) hasBeenClaimed;
    }

    function getStorage() internal pure returns (Storage storage ds) {
        bytes32 position = ONE_TIME_VERIFICATION_REWARD_CLAIM_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
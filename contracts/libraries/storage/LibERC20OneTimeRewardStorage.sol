// SPDX-License-Identifier: MIT
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  */
 
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
// SPDX-License-Identifier: MIT
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  */

pragma solidity ^0.8.0;

library LibERC20TimeClaimableStorage {
    bytes32 constant ERC20_TIME_CLAIMABLE_STORAGE_POSITION =
        keccak256("timeclaimable.erc20.diamond.storage.position");

    struct Storage {
        uint256 timeTillReward;
        uint256 maxTimeRewarded;
        mapping(address => uint256) lastClaim;
    }

    function getStorage() internal pure returns (Storage storage ds) {
        bytes32 position = ERC20_TIME_CLAIMABLE_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
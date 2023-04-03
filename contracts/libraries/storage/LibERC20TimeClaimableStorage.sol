// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library LibERC20TimeClaimableStorage {
    bytes32 constant ERC20_TIME_CLAIMABLE_STORAGE_POSITION =
        keccak256("timeclaimable.erc20.diamond.storage.position");

    struct Storage {
        mapping(uint256 => uint256) rewardForTier;
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
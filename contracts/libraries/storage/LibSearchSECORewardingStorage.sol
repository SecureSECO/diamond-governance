// SPDX-License-Identifier: MIT
/**
 * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
 * © Copyright Utrecht University (Department of Information and Computing Sciences)
 */

pragma solidity ^0.8.0;

library LibSearchSECORewardingStorage {
    bytes32 constant SEARCHSECO_REWARDING_STORAGE_POSITION =
        keccak256("searchseco.rewarding.diamond.storage.position");

    struct Storage {
        /// @notice The total number of hashes a user has submitted
        mapping(address => uint) hashCount;
        address signer;
    }

    function getStorage() internal pure returns (Storage storage ds) {
        bytes32 position = SEARCHSECO_REWARDING_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}

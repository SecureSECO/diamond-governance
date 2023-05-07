// SPDX-License-Identifier: MIT
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  */

pragma solidity ^0.8.0;

library LibVerificationStorage {
    bytes32 constant VERIFICATION_STORAGE_POSITION =
        keccak256("verification.diamond.storage.position");

    struct Storage {
        /// @notice mapping from whitelisted address to timestamp of whitelisting
        mapping(address => uint64) whitelistTimestamps;
        /// @notice mapping from providerId to tier score
        mapping(string => uint256) tierMapping;
        address verificationContractAddress;
    }

    function getStorage() internal pure returns (Storage storage ds) {
        bytes32 position = VERIFICATION_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
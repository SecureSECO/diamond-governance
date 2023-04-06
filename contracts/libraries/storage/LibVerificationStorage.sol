// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library LibVerificationStorage {
    bytes32 constant VERIFICATION_STORAGE_POSITION =
        keccak256("verification.diamond.storage.position");

    struct Storage {
        // mapping from whitelisted address to timestamp of whitelisting
        mapping(address => uint64) whitelistTimestamps;
        // mapping from providerId to tier score
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
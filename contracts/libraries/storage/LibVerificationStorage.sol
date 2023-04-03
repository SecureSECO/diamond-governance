// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library LibVerificationStorage {
    bytes32 constant VERIFICATION_STORAGE_POSITION =
        keccak256("verification.diamond.storage.position");

    struct VerificationStorage {
        // mapping from whitelisted address to timestamp of whitelisting
        mapping(address => uint256) whitelistTimestamps;
        address verificationContractAddress;
    }

    function verificationStorage() internal pure returns (VerificationStorage storage ds) {
        bytes32 position = VERIFICATION_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
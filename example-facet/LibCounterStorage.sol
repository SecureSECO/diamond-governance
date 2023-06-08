// SPDX-License-Identifier: MIT
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  */

pragma solidity ^0.8.0;

library LibCounterStorage {
    bytes32 constant COUNTER_STORAGE_POSITION =
        keccak256("counter.diamond.storage.position"); // This should be a unique hash!

    // Put your storage variables here
    struct Storage {
        uint myNumber;
        // plus any other storage variables you might want...
    }

    function getStorage() internal pure returns (Storage storage ds) {
        bytes32 position = COUNTER_STORAGE_POSITION; // don't forget to change this variable name
        assembly {
            ds.slot := position
        }
    }
}
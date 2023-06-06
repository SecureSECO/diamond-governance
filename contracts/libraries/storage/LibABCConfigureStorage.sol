// SPDX-License-Identifier: MIT
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  */

pragma solidity ^0.8.0;

import { Counters } from "@openzeppelin/contracts/utils/Counters.sol";

library LibABCConfigureStorage {
    using Counters for Counters.Counter;
    
    bytes32 constant ABC_CONFIGURE_STORAGE_POSITION =
        keccak256("configure.abc.diamond.storage.position");

    struct Storage {
        address marketMaker;
    }

    function getStorage() internal pure returns (Storage storage ds) {
        bytes32 position = ABC_CONFIGURE_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
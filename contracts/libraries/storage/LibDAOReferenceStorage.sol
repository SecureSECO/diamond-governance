// SPDX-License-Identifier: MIT
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  */

pragma solidity ^0.8.0;

import { IDAO } from "@aragon/osx/core/dao/IDAO.sol";

library LibDAOReferenceStorage {
    bytes32 constant DAOREFERENCE_STORAGE_POSITION =
        keccak256("daoreference.diamond.storage.position");

    struct Storage {
        IDAO dao;
    }

    function getStorage() internal pure returns (Storage storage ds) {
        bytes32 position = DAOREFERENCE_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
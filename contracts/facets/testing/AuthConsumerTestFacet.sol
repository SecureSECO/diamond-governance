// SPDX-License-Identifier: MIT
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  *
  * This source code is licensed under the MIT license found in the
  * LICENSE file in the root directory of this source tree.
  */
 
pragma solidity ^0.8.0;

import { AuthConsumer } from "../../utils/AuthConsumer.sol";
import { IFacet } from "../IFacet.sol";

library AuthConsumerTestFacetStorage {
    bytes32 constant STORAGE_POSITION =
        keccak256("AuthConsumerTestFacet");

    struct Storage {
        bool executed;
    }

    function getStorage() internal pure returns (Storage storage ds) {
        bytes32 position = STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}

contract AuthConsumerTestFacet is AuthConsumer, IFacet {
    bytes32 public constant AUTH_CONSUMER_TEST_PERMISSION_ID = keccak256("AUTH_CONSUMER_TEST_PERMISSION");

    function Execute() external auth(AUTH_CONSUMER_TEST_PERMISSION_ID) {
        AuthConsumerTestFacetStorage.getStorage().executed = true;
    }

    function hasExecuted() external view returns (bool) {
      return AuthConsumerTestFacetStorage.getStorage().executed;
    }
}
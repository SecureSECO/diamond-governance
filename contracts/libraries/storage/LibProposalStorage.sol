// SPDX-License-Identifier: MIT
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  */

pragma solidity ^0.8.0;

import { Counters } from "@openzeppelin/contracts/utils/Counters.sol";

library LibProposalStorage {
    bytes32 constant PROPOSAL_STORAGE_POSITION =
        keccak256("proposal.diamond.storage.position");

    struct Storage {
        /// @notice The incremental ID for proposals and executions.
        Counters.Counter proposalCounter;
    }

    function getStorage() internal pure returns (Storage storage ds) {
        bytes32 position = PROPOSAL_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
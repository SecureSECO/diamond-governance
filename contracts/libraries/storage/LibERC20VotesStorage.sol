// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { ERC20VotesFacet } from "../../facets/token/ERC20/core/ERC20VotesFacet.sol";

library LibERC20VotesStorage {
    bytes32 constant ERC20_VOTES_STORAGE_POSITION =
        keccak256("votes.erc20.diamond.storage.position");

    struct Storage {
        mapping(address => address) delegates;
        mapping(address => ERC20VotesFacet.Checkpoint[]) checkpoints;
        ERC20VotesFacet.Checkpoint[] totalSupplyCheckpoints;
    }

    function getStorage() internal pure returns (Storage storage ds) {
        bytes32 position = ERC20_VOTES_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Counters } from "@openzeppelin/contracts/utils/Counters.sol";

library LibERC20PermitStorage {
    using Counters for Counters.Counter;
    
    bytes32 constant ERC20_PERMIT_STORAGE_POSITION =
        keccak256("permit.erc20.diamond.storage.position");

    struct Storage {
        mapping(address => Counters.Counter) nonces;
    }

    function getStorage() internal pure returns (Storage storage ds) {
        bytes32 position = ERC20_PERMIT_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
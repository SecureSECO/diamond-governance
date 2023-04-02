// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Counters } from "@openzeppelin/contracts/utils/Counters.sol";

library LibERC20PermitStorage {
    using Counters for Counters.Counter;
    
    bytes32 constant ERC20_PERMIT_STORAGE_POSITION =
        keccak256("erc20.permit.diamond.storage.position");

    struct ERC20PermitStorage {
        mapping(address => Counters.Counter) nonces;
    }

    function erc20PermitStorage() internal pure returns (ERC20PermitStorage storage ds) {
        bytes32 position = ERC20_PERMIT_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
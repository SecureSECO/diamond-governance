// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library LibERC20Storage {
    bytes32 constant ERC20_STORAGE_POSITION =
        keccak256("erc20.diamond.storage.position");

    struct ERC20Storage {
        mapping(address => uint256) balances;
        mapping(address => mapping(address => uint256)) allowances;
        uint256 totalSupply;
        string name;
        string symbol;
    }

    function erc20Storage() internal pure returns (ERC20Storage storage ds) {
        bytes32 position = ERC20_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
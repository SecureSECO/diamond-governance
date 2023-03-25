// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.8.17;

import "hardhat/console.sol";

contract StorageExample {

    uint public variable;

    function setVariable(uint value) public {
        console.log("Variable updated from %s to %s", variable, value);
        variable = value;
    }
}

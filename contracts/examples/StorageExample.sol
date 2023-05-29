// SPDX-License-Identifier: AGPL-3.0-or-later
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  */


pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract StorageExample {

    uint public variable;

    function setVariable(uint value) public {
        console.log("Variable updated from %s to %s", variable, value);
        variable = value;
    }
}
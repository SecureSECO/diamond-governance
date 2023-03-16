// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.8.17;

contract StorageExample {

    uint public variable;

    function setVariable(uint value) public {
        variable = value;
    }
}

// SPDX-License-Identifier: MIT
/**
 * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
 * © Copyright Utrecht University (Department of Information and Computing Sciences)
 */

pragma solidity ^0.8.0;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ERC20MonetaryToken is ERC20 {
    bool private isInited = false;

    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_) {

    }

    function init(address _address, uint256 _amount) external virtual {
        require(!isInited, "Already inited");

        _mint(_address, _amount);
        isInited = true;
    }
}

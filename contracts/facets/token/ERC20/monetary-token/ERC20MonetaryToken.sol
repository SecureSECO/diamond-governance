// SPDX-License-Identifier: MIT
/**
 * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
 * © Copyright Utrecht University (Department of Information and Computing Sciences)
 */

// Based on non-facet implementation by OpenZeppelin (https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol)
pragma solidity ^0.8.0;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {AuthConsumer} from "../../../../utils/AuthConsumer.sol";
import {IMintable} from "./IMintable.sol";

contract ERC20MonetaryToken is ERC20, IMintable, Ownable {
    constructor(
        string memory name_,
        string memory symbol_
    ) ERC20(name_, symbol_) {}

    /// @notice External function to call the internal inherited _mint function to mint tokens (ERC20)
    /// @param _account Recipient of the mint
    /// @param _amount Amount of tokens to mint
    function mint(address _account, uint _amount) external onlyOwner {
        _mint(_account, _amount);
    }
}

// SPDX-License-Identifier: MIT
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  */

// Based on non-facet implementation by OpenZeppelin (https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol)
pragma solidity ^0.8.0;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract ERC20SearchSECOToken is ERC20, Ownable {
  constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_) {}

  /// @notice External function to call the internal inherited _mint function to mint tokens (ERC20)
  /// @param account Recipient of the mint
  /// @param amount Amount of tokens to mint
  function mint(address account, uint amount) external onlyOwner {
    _mint(account, amount);
  }
}
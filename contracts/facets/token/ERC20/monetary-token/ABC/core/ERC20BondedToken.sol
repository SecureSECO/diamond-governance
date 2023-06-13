// SPDX-License-Identifier: MIT
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  */
pragma solidity ^0.8.0;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { PluginStandalone } from "../standalone/PluginStandalone.sol";
import { IBondedToken } from "../interfaces/IBondedToken.sol";

contract ERC20BondedToken is ERC20, PluginStandalone, IBondedToken {
    /// @notice The permission identifier to mint new tokens
    bytes32 public constant MINT_PERMISSION_ID = keccak256("MINT_PERMISSION");

    /// @notice The permission identifier to burn existing tokens
    bytes32 public constant BURN_PERMISSION_ID = keccak256("BURN_PERMISSION");

    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_) {

    }

    function mint(address to, uint256 amount) external virtual override auth(MINT_PERMISSION_ID) {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external virtual override auth(BURN_PERMISSION_ID) {
        _burn(from, amount);
    }
}
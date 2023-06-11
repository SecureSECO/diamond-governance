// SPDX-License-Identifier: MIT
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  */

// https://github.com/DAObox/liquid-protocol/blob/main/src/interfaces/IBondedToken.sol
pragma solidity >=0.8.17;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title IBonded Token
 * @author DAOBox | (@pythonpete32)
 * @dev
 */
interface IBondedToken is IERC20 {
    function mint(address to, uint256 amount) external;
    function burn(address from, uint256 amount) external;
}
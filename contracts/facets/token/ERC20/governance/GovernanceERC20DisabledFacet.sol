// SPDX-License-Identifier: MIT
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  */

pragma solidity ^0.8.0;

import { ERC20VotesDisabledFacet } from "../core/disabled/ERC20VotesDisabledFacet.sol";

/**
 * @title GovernanceERC20DisabledFacet
 * @author Utrecht University
 * @notice This facet converts ERC20VotesDisabledFacet to a disable variant of GovernanceERC20.
 * @dev Currently does not need any changes compared to ERC20VotesDisabledFacet.
 */
contract GovernanceERC20DisabledFacet is ERC20VotesDisabledFacet {
}
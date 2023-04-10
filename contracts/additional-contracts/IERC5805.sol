// SPDX-License-Identifier: MIT
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  */

// OpenZeppelin Contracts (interfaces/IERC5805.sol)
// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/interfaces/IERC5805.sol

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/governance/utils/IVotes.sol";
import "./IERC6372.sol";

interface IERC5805 is IERC6372, IVotes {}
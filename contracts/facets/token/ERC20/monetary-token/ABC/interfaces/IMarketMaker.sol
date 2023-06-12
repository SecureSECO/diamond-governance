// SPDX-License-Identifier: MIT
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  */
pragma solidity ^0.8.0;

import { CurveParameters } from "../lib/Types.sol";

interface IMarketMaker {
    function hatch(uint256 initialSupply, address hatchTo) external;
    function getCurveParameters() external view returns (CurveParameters memory);
    function setGovernance(bytes32 what, bytes memory value) external;
}
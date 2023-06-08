// SPDX-License-Identifier: MIT
/**
 * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
 * © Copyright Utrecht University (Department of Information and Computing Sciences)
 */

pragma solidity ^0.8.0;

interface ICounterFacet {
  /// @notice This function increments a number by 1
  /// @return uint The new value of our number
  function incrementCounter() external returns (uint);

  /// @notice This function returns our number
  /// @return uint The value of our number
  function getMyNumber() external view returns (uint);

  /// @notice This function sets our number
  /// @param _myNumber The new value of our number
  function setMyNumber(uint _myNumber) external;
}
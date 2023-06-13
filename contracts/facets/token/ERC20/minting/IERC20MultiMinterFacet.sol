// SPDX-License-Identifier: MIT
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  */

pragma solidity ^0.8.0;

/**
 * @title IERC20MultiMinterFacet
 * @author Utrecht University
 * @notice This interface allows a single proposal action to perform multiple mint actions, saving gas fees.
 */
interface IERC20MultiMinterFacet {
    function multimint(address[] calldata _addresses, uint256[] calldata _amounts) external;
}
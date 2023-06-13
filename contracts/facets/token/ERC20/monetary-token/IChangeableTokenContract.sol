// SPDX-License-Identifier: AGPL-3.0-or-later
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  */


pragma solidity ^0.8.0;


/**
 * @title IChangeableTokenContract
 * @author Utrecht University
 * @notice This interface allows getting and setting the monetary token contract address.
 */
interface IChangeableTokenContract {
    /// @notice This returns the contract address of the token contract used
    /// @return address The contract address of the token contract
    function getTokenContractAddress() external view returns (address);

    /// @notice Sets the contract address of the token contract used
    /// @param _tokenContractAddress The contract address of the token contract
    function setTokenContractAddress(address _tokenContractAddress) external;
}
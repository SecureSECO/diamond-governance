// SPDX-License-Identifier: AGPL-3.0-or-later
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  */


pragma solidity ^0.8.0;

/// @title IMonetaryTokenMintable
/// @author Utrecht University - 2023
/// @notice The interface for the monetary token facet. 
/// @dev This interface provides the mintMonetaryToken function.
interface IMonetaryTokenMintable {
    /// @notice Function to mint SECOIN tokens
    /// @param _account The address to receive the minted tokens
    /// @param _amount The amount of tokens to mint
    function mintMonetaryToken(address _account, uint _amount) external;
}
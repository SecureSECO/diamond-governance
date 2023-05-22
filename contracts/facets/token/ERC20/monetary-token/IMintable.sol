// SPDX-License-Identifier: AGPL-3.0-or-later
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  */


pragma solidity ^0.8.0;

/// @title IMonetaryToken
/// @author Utrecht University - 2023
/// @notice The interface of the monetary token. 
/// @dev This interface exposes the mint function.
interface IMintable {
    /// @notice Function to mint tokens
    /// @param _account The address to receive the minted tokens
    /// @param _amount The amount of tokens to mint
    function mint(address _account, uint _amount) external;
}
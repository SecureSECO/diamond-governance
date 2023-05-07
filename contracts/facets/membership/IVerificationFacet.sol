// SPDX-License-Identifier: AGPL-3.0-or-later
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  */


pragma solidity ^0.8.0;

import { GithubVerification } from "../../verification/GithubVerification.sol";

/// @title IVerificationFacet
/// @author Utrecht University - 2023
/// @notice The interface of the verification plugin.
abstract contract IVerificationFacet {
    /// @notice Returns all stamps of an account.
    /// @param _address The address to get stamps from.
    /// @return stamps The stamps of the account.
    function getStamps(address _address) external view virtual returns (GithubVerification.Stamp[] memory);

    /// @notice Returns stamps of an account at a given timestamp
    /// @param _address The address to get stamps from
    /// @param _timestamp The timestamp to get stamps at
    /// @return stamps The stamps of the account.
    function getStampsAt(address _address, uint _timestamp) public view virtual returns (GithubVerification.Stamp[] memory);

    /// @notice Returns the current verification contract address
    /// @return address of the verification contract
    function getVerificationContractAddress() external view virtual returns (address);
}
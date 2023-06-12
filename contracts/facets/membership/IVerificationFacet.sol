// SPDX-License-Identifier: AGPL-3.0-or-later
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  */


pragma solidity ^0.8.0;

import { SignVerification } from "../../other/verification/SignVerification.sol";

/// @title IVerificationFacet
/// @author Utrecht University - 2023
/// @notice The interface of the verification plugin.
interface IVerificationFacet {
    /// @notice Returns all stamps of an account.
    /// @param _address The address to get stamps from.
    /// @return stamps The stamps of the account.
    function getStamps(address _address) external view returns (SignVerification.Stamp[] memory);

    /// @notice Returns stamps of an account at a given timestamp
    /// @param _address The address to get stamps from
    /// @param _timestamp The timestamp to get stamps at
    /// @return stamps The stamps of the account.
    function getStampsAt(address _address, uint _timestamp) external view returns (SignVerification.Stamp[] memory);

    /// @notice Returns the current verification contract address
    /// @return address of the verification contract
    function getVerificationContractAddress() external view returns (address);

    function getTierMapping(string calldata _providerId) external view returns (uint256);

    /// @notice Updates a "tier" score for a given provider. This can be used to either score new providers or update
    /// scores of already scored providers
    /// @dev This maps a providerId to a uint256 tier
    function setTierMapping(string calldata _providerId, uint256 _tier) external;
}
// SPDX-License-Identifier: AGPL-3.0-or-later
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  */


pragma solidity ^0.8.0;

import { SignVerification } from "../../other/verification/SignVerification.sol";

/**
 * @title IVerificationFacet
 * @author Utrecht University
 * @notice This interface defines verification stamps that wallets can have.
 */
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

    /// @notice Updates the verification contract address
    /// @param _verificationContractAddress The new verification contract address
    function setVerificationContractAddress(address _verificationContractAddress) external;

    /// @notice Returns the current verification contract address
    function getTierMapping(string calldata _providerId) external view returns (uint256);

    /// @notice Updates a "tier" score for a given provider. This can be used to either score new providers or update
    /// scores of already scored providers
    /// @dev This maps a providerId to a uint256 tier
    function setTierMapping(string calldata _providerId, uint256 _tier) external;

    /// @notice Returns the amount of days that a stamp is valid for (latest value)
    /// @dev This function interacts with the verification contract to get the day threshold
    function getVerifyDayThreshold() external view returns (uint64);

    /// @notice Updates the amount of days that a stamp is valid for
    /// @dev This function interacts with the verification contract to update the day threshold
    /// @param _verifyDayThreshold The new amount of days that a stamp is valid for
    function setVerifyDayThreshold(uint64 _verifyDayThreshold) external;

    /// @notice Returns the amount of days that a stamp is valid for
    /// @dev This function interacts with the verification contract to get the reverification threshold
    function getReverifyThreshold() external view returns (uint64);

    /// @notice Updates the amount of days that a stamp is valid for
    /// @dev This function interacts with the verification contract to update the reverification threshold
    /// @param _reverifyDayThreshold The new amount of days that a stamp is valid for
    function setReverifyThreshold(uint64 _reverifyDayThreshold) external;
}
// SPDX-License-Identifier: MIT
/**
 * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
 * © Copyright Utrecht University (Department of Information and Computing Sciences)
 */

pragma solidity ^0.8.0;

/// @title IVerificationRewardPoolFacet
/// @author Utrecht University - 2023
/// @notice The interface fo the verification reward pool.
interface IVerificationRewardPoolFacet {
    function getVerificationRewardPool() external view returns (uint256);

    function increaseVerificationRewardPool(uint _amount) external;

    function decreaseVerificationRewardPool(uint _amount) external;

    function rewardCoinsToVerifyer(address _miner, uint _amount) external;
}

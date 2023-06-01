// SPDX-License-Identifier: AGPL-3.0-or-later
/**
 * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
 * © Copyright Utrecht University (Department of Information and Computing Sciences)
 */

pragma solidity ^0.8.0;

/// @title IMiningRewardPoolFacet
/// @author Utrecht University - 2023
/// @notice The interface fo the mining reward pool.
interface IMiningRewardPoolFacet {
    function getMiningRewardPool() external view returns (uint256);

    function increaseMiningRewardPool(uint _amount) external;

    function decreaseMiningRewardPool(uint _amount) external;
}

// SPDX-License-Identifier: MIT
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  *
  * This source code is licensed under the MIT license found in the
  * LICENSE file in the root directory of this source tree.
  */
 
pragma solidity ^0.8.0;

/**
 * @title IDAOReferenceFacet
 * @author Utrecht University
 * @notice This interface allows different time claim reward per member tier.
 */
interface IERC20TieredTimeClaimableFacet {
    function getClaimReward(uint256 _tier) external view returns (uint256);

    function setClaimReward(uint256 _tier, uint256 _reward) external;
}
// SPDX-License-Identifier: MIT
/**
 * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
 * © Copyright Utrecht University (Department of Information and Computing Sciences)
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

pragma solidity ^0.8.0;

interface IERC20OneTimeRewardFacet {
    function tokensClaimableOneTime() external view returns (uint256 amount);

    function claimOneTime() external;

    function getOneTimeReward() external view returns (uint256);

    function setOneTimeReward(uint256 _oneTimeReward) external;
}

// SPDX-License-Identifier: MIT
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  *
  * This source code is licensed under the MIT license found in the
  * LICENSE file in the root directory of this source tree.
  */
 
pragma solidity ^0.8.0;

import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";

import { ERC20ClaimableFacet } from "../ERC20ClaimableFacet.sol";
import { AuthConsumer } from "../../../../../utils/AuthConsumer.sol";

import { LibERC20OneTimeRewardStorage } from "../../../../../libraries/storage/LibERC20OneTimeRewardStorage.sol";

library ERC20OneTimeRewardFacetInit {
    struct InitParams {
        uint256 reward;
    }

    function init(InitParams calldata _params) external {
        LibERC20OneTimeRewardStorage.getStorage().reward = _params.reward;
    }
}

contract ERC20OneTimeRewardFacet is ERC20ClaimableFacet, AuthConsumer {
    /// @notice The permission to update claim reward and period
    bytes32 public constant UPDATE_ONE_TIME_REWARD_SETTINGS_PERMISSION_ID = keccak256("UPDATE_ONE_TIME_REWARD_SETTINGS_PERMISSION");

    function tokensClaimable() external view virtual returns (uint256 amount) {
        return _tokensClaimable(msg.sender);
    }

    function claimOneTime() external virtual {
        _claim(msg.sender);
    }

    /// @inheritdoc ERC20ClaimableFacet
    function _tokensClaimable(address _claimer) internal view virtual override returns (uint256 amount) {
        return Math.max(0, LibERC20OneTimeRewardStorage.getStorage().reward - LibERC20OneTimeRewardStorage.getStorage().hasClaimed[_claimer]);
    }

    /// @inheritdoc ERC20ClaimableFacet
    function _afterClaim(address _claimer) internal virtual override {
        LibERC20OneTimeRewardStorage.getStorage().hasClaimed[_claimer] = LibERC20OneTimeRewardStorage.getStorage().reward;
    }

    function setOneTimeReward(uint256 _reward) external auth(UPDATE_ONE_TIME_REWARD_SETTINGS_PERMISSION_ID) {
        _setOneTimeReward(_reward);
    }

    function _setOneTimeReward(uint256 _reward) internal virtual {
        LibERC20OneTimeRewardStorage.getStorage().reward = _reward;
    }
}
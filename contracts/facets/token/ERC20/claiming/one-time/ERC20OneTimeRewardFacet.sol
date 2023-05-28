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

import { IERC20OneTimeRewardFacet } from "./IERC20OneTimeRewardFacet.sol";
import { IERC20ClaimableFacet } from "../IERC20ClaimableFacet.sol";
import { AuthConsumer } from "../../../../../utils/AuthConsumer.sol";
import { IFacet } from "../../../../IFacet.sol";

import { LibERC20OneTimeRewardStorage } from "../../../../../libraries/storage/LibERC20OneTimeRewardStorage.sol";

contract ERC20OneTimeRewardFacet is IERC20OneTimeRewardFacet, IERC20ClaimableFacet, AuthConsumer {
    /// @notice The permission to update claim reward
    bytes32 public constant UPDATE_ONE_TIME_REWARD_SETTINGS_PERMISSION_ID = keccak256("UPDATE_ONE_TIME_REWARD_SETTINGS_PERMISSION");

    struct ERC20OneTimeRewardFacetInitParams {
        uint256 reward;
    }

    /// @inheritdoc IFacet
    function init(bytes memory _initParams) public virtual override {
        ERC20OneTimeRewardFacetInitParams memory _params = abi.decode(_initParams, (ERC20OneTimeRewardFacetInitParams));
        __ERC20OneTimeRewardFacet_init(_params);
    }

    function __ERC20OneTimeRewardFacet_init(ERC20OneTimeRewardFacetInitParams memory _params) public virtual {
        LibERC20OneTimeRewardStorage.getStorage().reward = _params.reward;

        registerInterface(type(IERC20OneTimeRewardFacet).interfaceId);
    }

    /// @inheritdoc IFacet
    function deinit() public virtual override {
        unregisterInterface(type(IERC20OneTimeRewardFacet).interfaceId);
        super.deinit();
    }

    /// @inheritdoc IERC20OneTimeRewardFacet
    function tokensClaimableOneTime() external view virtual returns (uint256 amount) {
        return _tokensClaimable(msg.sender);
    }

    /// @inheritdoc IERC20OneTimeRewardFacet
    function claimOneTime() external virtual {
        _claim(msg.sender);
    }

    /// @inheritdoc IERC20ClaimableFacet
    function _tokensClaimable(address _claimer) internal view virtual override returns (uint256 amount) {
        return Math.max(0, LibERC20OneTimeRewardStorage.getStorage().reward - LibERC20OneTimeRewardStorage.getStorage().hasClaimed[_claimer]);
    }

    /// @inheritdoc IERC20ClaimableFacet
    function _afterClaim(address _claimer) internal virtual override {
        LibERC20OneTimeRewardStorage.getStorage().hasClaimed[_claimer] = LibERC20OneTimeRewardStorage.getStorage().reward;
    }

    /// @inheritdoc IERC20OneTimeRewardFacet
    function getOneTimeReward() external view virtual override returns (uint256) {
        return LibERC20OneTimeRewardStorage.getStorage().reward;
    }

    /// @inheritdoc IERC20OneTimeRewardFacet
    function setOneTimeReward(uint256 _reward) external virtual override auth(UPDATE_ONE_TIME_REWARD_SETTINGS_PERMISSION_ID) {
        LibERC20OneTimeRewardStorage.getStorage().reward = _reward;
    }
}
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

import { IERC20TimeClaimableFacet } from "./IERC20TimeClaimableFacet.sol";
import { IERC20ClaimableFacet } from "../IERC20ClaimableFacet.sol";
import { ITieredMembershipStructure } from "../../../../../facets/governance/structure/membership/ITieredMembershipStructure.sol";
import { AuthConsumer } from "../../../../../utils/AuthConsumer.sol";
import { IRewardMultiplierFacet } from "../../../../multiplier/IRewardMultiplierFacet.sol";

import { LibERC20TimeClaimableStorage } from "../../../../../libraries/storage/LibERC20TimeClaimableStorage.sol";
import { IFacet } from "../../../../../facets/IFacet.sol";

contract ERC20TimeClaimableFacet is IERC20TimeClaimableFacet, IERC20ClaimableFacet, AuthConsumer {
    /// @notice The permission to update claim reward and period
    bytes32 public constant UPDATE_CLAIM_SETTINGS_PERMISSION_ID = keccak256("UPDATE_CLAIM_SETTINGS_PERMISSION");

    struct ERC20TimeClaimableFacetInitParams {
        uint256 timeTillReward;
        uint256 maxTimeRewarded;
    }

    /// @inheritdoc IFacet
    function init(bytes memory _initParams) public virtual override {
        ERC20TimeClaimableFacetInitParams memory _params = abi.decode(_initParams, (ERC20TimeClaimableFacetInitParams));
        __ERC20TimeClaimableFacet_init(_params);
    }

    function __ERC20TimeClaimableFacet_init(ERC20TimeClaimableFacetInitParams memory _params) public virtual {
        LibERC20TimeClaimableStorage.Storage storage s = LibERC20TimeClaimableStorage.getStorage();
        s.timeTillReward = _params.timeTillReward;
        s.maxTimeRewarded = _params.maxTimeRewarded;

        registerInterface(type(IERC20TimeClaimableFacet).interfaceId);
    }

    /// @inheritdoc IFacet
    function deinit() public virtual override {
        unregisterInterface(type(IERC20TimeClaimableFacet).interfaceId);
        super.deinit();
    }

    function tokensClaimableTime() external view virtual returns (uint256 amount) {
        return _tokensClaimable(msg.sender);
    }

    function claimTime() external virtual {
        _claim(msg.sender);
    }

    /// @inheritdoc IERC20ClaimableFacet
    function _tokensClaimable(address _claimer) internal view virtual override returns (uint256 amount) {
        return _tokensClaimableAt(_claimer, block.timestamp);
    }

    /// @inheritdoc IERC20ClaimableFacet
    function _afterClaim(address _claimer) internal virtual override {
        LibERC20TimeClaimableStorage.getStorage().lastClaim[_claimer] = block.timestamp;
    }

    /// @inheritdoc IERC20TimeClaimableFacet
    function getClaimPeriodInterval() external view virtual override returns (uint256) {
        return LibERC20TimeClaimableStorage.getStorage().timeTillReward;
    }

    /// @inheritdoc IERC20TimeClaimableFacet
    function setClaimPeriodInterval(uint256 _claimPeriodInterval) external auth(UPDATE_CLAIM_SETTINGS_PERMISSION_ID) {
        LibERC20TimeClaimableStorage.getStorage().timeTillReward = _claimPeriodInterval;
    }

    /// @inheritdoc IERC20TimeClaimableFacet
    function getClaimPeriodMax() external view virtual override returns (uint256) {
        return  LibERC20TimeClaimableStorage.getStorage().maxTimeRewarded;
    }

    /// @inheritdoc IERC20TimeClaimableFacet
    function setClaimPeriodMax(uint256 _claimPeriodMax) external auth(UPDATE_CLAIM_SETTINGS_PERMISSION_ID) {
        LibERC20TimeClaimableStorage.getStorage().maxTimeRewarded = _claimPeriodMax;
    }

    function _tokensClaimableAt(address _claimer, uint256 _timeStamp) internal view virtual returns (uint256 amount) {
        LibERC20TimeClaimableStorage.Storage storage s = LibERC20TimeClaimableStorage.getStorage();
        // uint256 timePassed = _timeStamp - s.lastClaim[_claimer];
        // uint256 timeRewarded = Math.min(s.maxTimeRewarded, timePassed);
        // return timeRewarded / s.timeTillReward;

        // Apply (inflation) multiplier to the amount of tokens claimable (based on time passed since last claim)
        return IRewardMultiplierFacet(address(this)).applyMultiplier("inflation", Math.min(s.maxTimeRewarded, _timeStamp - s.lastClaim[_claimer]) / s.timeTillReward);
    }
}
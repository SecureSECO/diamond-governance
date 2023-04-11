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
import { ITieredMembershipStructure } from "../../../../../facets/governance/structure/membership/ITieredMembershipStructure.sol";
import { AuthConsumer } from "../../../../../utils/AuthConsumer.sol";

import { LibERC20TimeClaimableStorage } from "../../../../../libraries/storage/LibERC20TimeClaimableStorage.sol";

library ERC20TimeClaimableFacetInit {
    struct InitParams {
        uint256 timeTillReward;
        uint256 maxTimeRewarded;
    }

    function init(InitParams calldata _params) external {
        LibERC20TimeClaimableStorage.getStorage().timeTillReward = _params.timeTillReward;
        LibERC20TimeClaimableStorage.getStorage().maxTimeRewarded = _params.maxTimeRewarded;
    }
}

contract ERC20TimeClaimableFacet is ERC20ClaimableFacet, AuthConsumer {
    /// @notice The permission to update claim reward and period
    bytes32 public constant UPDATE_CLAIM_SETTINGS_PERMISSION_ID = keccak256("UPDATE_CLAIM_SETTINGS_PERMISSION");

    function tokensClaimableTime() external view virtual returns (uint256 amount) {
        return _tokensClaimable(msg.sender);
    }

    function claimTime() external virtual {
        _claim(msg.sender);
    }

    /// @inheritdoc ERC20ClaimableFacet
    function _tokensClaimable(address _claimer) internal view virtual override returns (uint256 amount) {
        return _tokensClaimableAt(_claimer, block.timestamp);
    }

    /// @inheritdoc ERC20ClaimableFacet
    function _afterClaim(address _claimer) internal virtual override {
        LibERC20TimeClaimableStorage.getStorage().lastClaim[_claimer] = block.timestamp;
    }

    function setClaimPeriodInterval(uint256 _timeTillReward) external auth(UPDATE_CLAIM_SETTINGS_PERMISSION_ID) {
        _setClaimPeriodInterval(_timeTillReward);
    }

    function _setClaimPeriodInterval(uint256 _timeTillReward) internal virtual {
        LibERC20TimeClaimableStorage.getStorage().timeTillReward = _timeTillReward;
    }

    function setClaimPeriodMax(uint256 _maxTimeRewarded) external auth(UPDATE_CLAIM_SETTINGS_PERMISSION_ID) {
        _setClaimPeriodMax(_maxTimeRewarded);
    }

    function _setClaimPeriodMax(uint256 _maxTimeRewarded) internal virtual {
        LibERC20TimeClaimableStorage.getStorage().maxTimeRewarded = _maxTimeRewarded;
    }

    function _tokensClaimableAt(address _claimer, uint256 _timeStamp) internal view virtual returns (uint256 amount) {
        LibERC20TimeClaimableStorage.Storage storage s = LibERC20TimeClaimableStorage.getStorage();
        // uint256 timePassed = _timeStamp - s.lastClaim[_claimer];
        // uint256 timeRewarded = Math.min(s.maxTimeRewarded, timePassed);
        // return timeRewarded / s.timeTillReward;
        return (Math.min(s.maxTimeRewarded, _timeStamp - s.lastClaim[_claimer]) / s.timeTillReward);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";

import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";

import { ERC20ClaimableFacet } from "./ERC20ClaimableFacet.sol";
import { ITieredMembershipStructure } from "../../../../facets/governance/structure/membership/ITieredMembershipStructure.sol";
import { AragonAuth } from "../../../../utils/AragonAuth.sol";

import { LibERC20TimeClaimableStorage } from "../../../../libraries/storage/LibERC20TimeClaimableStorage.sol";

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

// TODO, should be refactored to not use tiers and make a new contract that inherts from this, extending it with tiers
contract ERC20TimeClaimableFacet is ERC20ClaimableFacet, AragonAuth {
    /// @notice The permission to update claim reward and period
    bytes32 public constant UPDATE_CLAIM_SETTINGS_PERMISSION_ID = keccak256("UPDATE_CLAIM_SETTINGS_PERMISSION");

    function tokensClaimable(address _claimer) public view virtual override returns (uint256 amount) {
        return _tokensClaimableAt(_claimer, block.timestamp);
    }

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
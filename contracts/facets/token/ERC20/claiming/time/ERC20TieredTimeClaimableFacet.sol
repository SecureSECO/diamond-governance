// SPDX-License-Identifier: MIT
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  *
  * This source code is licensed under the MIT license found in the
  * LICENSE file in the root directory of this source tree.
  */
 
pragma solidity ^0.8.0;

import { IERC20TieredTimeClaimableFacet } from "./IERC20TieredTimeClaimableFacet.sol";
import { ERC20TimeClaimableFacet } from "./ERC20TimeClaimableFacet.sol";
import { ITieredMembershipStructure } from "../../../../../facets/governance/structure/membership/ITieredMembershipStructure.sol";

import { LibERC20TieredTimeClaimableStorage } from "../../../../../libraries/storage/LibERC20TieredTimeClaimableStorage.sol";
import { IFacet } from "../../../../../facets/IFacet.sol";

contract ERC20TieredTimeClaimableFacet is IERC20TieredTimeClaimableFacet, ERC20TimeClaimableFacet {
    struct ERC20TieredTimeClaimableFacetInitParams {
        uint256[] tiers;
        uint256[] rewards;
        ERC20TimeClaimableFacetInitParams _ERC20TimeClaimableFacetInitParams;
    }

    /// @inheritdoc IFacet
    function init(bytes memory _initParams) public virtual override {
        ERC20TieredTimeClaimableFacetInitParams memory _params = abi.decode(_initParams, (ERC20TieredTimeClaimableFacetInitParams));
        __ERC20TieredTimeClaimableFacet_init(_params);
    }

    function __ERC20TieredTimeClaimableFacet_init(ERC20TieredTimeClaimableFacetInitParams memory _params) public virtual {
        __ERC20TimeClaimableFacet_init(_params._ERC20TimeClaimableFacetInitParams);

        require (_params.tiers.length == _params.rewards.length, "Tiers and rewards should be same length");

        for (uint i; i < _params.tiers.length; ) {
            LibERC20TieredTimeClaimableStorage.getStorage().rewardForTier[_params.tiers[i]] = _params.rewards[i];
            unchecked {
                i++;
            }
        }
        
        registerInterface(type(IERC20TieredTimeClaimableFacet).interfaceId);
    }

    /// @inheritdoc IFacet
    function deinit() public virtual override {
        unregisterInterface(type(IERC20TieredTimeClaimableFacet).interfaceId);
        super.deinit();
    }

    function setClaimReward(uint256 _tier, uint256 _reward) external auth(UPDATE_CLAIM_SETTINGS_PERMISSION_ID) {
        _setClaimReward(_tier, _reward);
    }

    function _setClaimReward(uint256 _tier, uint256 _reward) internal virtual {
        LibERC20TieredTimeClaimableStorage.getStorage().rewardForTier[_tier] = _reward;
    }

    /// @inheritdoc ERC20TimeClaimableFacet
    function _tokensClaimableAt(address _claimer, uint256 _timeStamp) internal view virtual override returns (uint256 amount) {
        return super._tokensClaimableAt(_claimer, _timeStamp) * LibERC20TieredTimeClaimableStorage.getStorage().rewardForTier[ITieredMembershipStructure(address(this)).getTierAt(_claimer, _timeStamp)];
    }
}
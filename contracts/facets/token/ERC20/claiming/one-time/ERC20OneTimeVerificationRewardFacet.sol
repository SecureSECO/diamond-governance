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

import { ERC20ClaimableFacet, IMintableGovernanceStructure } from "../ERC20ClaimableFacet.sol";
import { AuthConsumer } from "../../../../../utils/AuthConsumer.sol";

import { LibERC20OneTimeVerificationRewardStorage } from "../../../../../libraries/storage/LibERC20OneTimeVerificationRewardStorage.sol";
import { GithubVerification } from "../../../../../verification/GithubVerification.sol";
import { VerificationFacet } from "../../../../membership/VerificationFacet.sol";

library ERC20OneTimeVerificationRewardFacetInit {
    struct InitParams {
        string[] providers;
        uint256[] rewards;
    }

    function init(InitParams calldata _params) external {
        require(_params.providers.length == _params.rewards.length, "Providers and rewards array length doesnt match");

        LibERC20OneTimeVerificationRewardStorage.Storage storage s = LibERC20OneTimeVerificationRewardStorage.getStorage();
        for (uint i; i < _params.providers.length; ) {
            s.providerReward[_params.providers[i]] = _params.rewards[i];
            unchecked {
                i++;
            }
        }
    }
}

contract ERC20OneTimeVerificationRewardFacet is ERC20ClaimableFacet, AuthConsumer {
    /// @inheritdoc ERC20ClaimableFacet
    function _tokensClaimable(address _claimer) internal view virtual override returns (uint256 amount) {
        // Get data from storage
        GithubVerification.Stamp[] memory stampsAt =  VerificationFacet(address(this)).getStampsAt(_claimer, block.timestamp);
        
        for (uint i; i < stampsAt.length; ) {
            uint amountClaimable = _tokensClaimableStamp(_claimer, stampsAt[i].providerId, stampsAt[i].userHash);
            if (amountClaimable != 0) {
                amount += amountClaimable;
            }

            unchecked {
                i++;
            }
        }
    }

    /// @inheritdoc ERC20ClaimableFacet
    function _afterClaim(address _claimer) internal virtual override {
        // Get data from storage
        GithubVerification.Stamp[] memory stampsAt = VerificationFacet(address(this)).getStampsAt(_claimer, block.timestamp);
        
        for (uint i; i < stampsAt.length; ) {
            _afterClaimStamp(_claimer, stampsAt[i].providerId, stampsAt[i].userHash);

            unchecked {
                i++;
            }
        }
    }

    function tokensClaimableVerificationRewardAll() external view virtual returns (uint256 amount) {
        return _tokensClaimable(msg.sender);
    }

    function claimVerificationRewardAll() external virtual {
        _claim(msg.sender);
    }

    
    function tokensClaimableVerificationRewardStamp(uint256 stampIndex) external view virtual returns (uint256 amount) {
        GithubVerification.Stamp[] memory stampsAt = VerificationFacet(address(this)).getStampsAt(msg.sender, block.timestamp);
        require(stampIndex < stampsAt.length, "Stamp index out of bound");
        return _tokensClaimableStamp(msg.sender, stampsAt[stampIndex].providerId, stampsAt[stampIndex].userHash);
    }

    function claimVerificationRewardStamp(uint256 stampIndex) external virtual {
        GithubVerification.Stamp[] memory stampsAt = VerificationFacet(address(this)).getStampsAt(msg.sender, block.timestamp);
        require(stampIndex < stampsAt.length, "Stamp index out of bound");
        IMintableGovernanceStructure(address(this)).mintVotingPower(msg.sender, 0, _tokensClaimableStamp(msg.sender, stampsAt[stampIndex].providerId, stampsAt[stampIndex].userHash));
        _afterClaimStamp(msg.sender, stampsAt[stampIndex].providerId, stampsAt[stampIndex].userHash);
    }

    function _afterClaimStamp(address _claimer, string memory _provider, string memory _stamp) internal virtual {
        LibERC20OneTimeVerificationRewardStorage.Storage storage s = LibERC20OneTimeVerificationRewardStorage.getStorage();
        s.amountClaimedByAddressForProvider[_claimer][_provider] = s.providerReward[_provider];
        s.amountClaimedForStamp[_stamp] = s.providerReward[_provider];
    }

    function _tokensClaimableStamp(address _claimer, string memory _provider, string memory _stamp) internal view virtual returns (uint256 amount) {
        LibERC20OneTimeVerificationRewardStorage.Storage storage s = LibERC20OneTimeVerificationRewardStorage.getStorage();
        return s.providerReward[_provider] - Math.max(s.amountClaimedByAddressForProvider[_claimer][_provider], s.amountClaimedForStamp[_stamp]);
    }
}
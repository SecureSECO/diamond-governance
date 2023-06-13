// SPDX-License-Identifier: MIT
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  *
  * This source code is licensed under the MIT license found in the
  * LICENSE file in the root directory of this source tree.
  */
 
pragma solidity ^0.8.0;

interface IERC20OneTimeVerificationRewardFacet {
    struct OneTimeVerificationReward {
        uint256 repReward;
        uint256 coinReward;
    }

    function tokensClaimableVerificationRewardAll() external view returns (OneTimeVerificationReward memory);

    function claimVerificationRewardAll() external;

    function tokensClaimableVerificationRewardStamp(uint256 _stampIndex) external view returns (OneTimeVerificationReward memory);

    function claimVerificationRewardStamp(uint256 _stampIndex) external;

    function getProviderReward(string calldata _provider) external view returns (OneTimeVerificationReward memory);

    function setProviderReward(string calldata _provider, OneTimeVerificationReward memory _reward) external;
}
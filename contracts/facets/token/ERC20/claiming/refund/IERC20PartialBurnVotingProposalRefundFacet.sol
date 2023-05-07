// SPDX-License-Identifier: MIT
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  *
  * This source code is licensed under the MIT license found in the
  * LICENSE file in the root directory of this source tree.
  */
 
pragma solidity ^0.8.0;

interface IERC20PartialBurnVotingProposalRefundFacet {
    function tokensRefundableFromProposalCreation(uint256 _proposalId, address _claimer) external view returns (uint256);

    function refundTokensFromProposalCreation(uint256 _proposalId) external;
}
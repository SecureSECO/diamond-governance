// SPDX-License-Identifier: MIT
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  *
  * This source code is licensed under the MIT license found in the
  * LICENSE file in the root directory of this source tree.
  */
 
pragma solidity ^0.8.0;

/**
 * @title IERC20PartialBurnVotingRefundFacet
 * @author Utrecht University
 * @notice This interface will refund the voting power used to vote on a proposal if it did not reach the participation threshold.
 * You can only refund voting power that got burned and will not be able to refund in case the proposal gets defeated due to approval threshold instead.
 */
interface IERC20PartialBurnVotingRefundFacet {
    function tokensRefundableFromProposal(uint256 _proposalId, address _claimer) external view returns (uint256);

    function refundTokensFromProposal(uint256 _proposalId) external;
}
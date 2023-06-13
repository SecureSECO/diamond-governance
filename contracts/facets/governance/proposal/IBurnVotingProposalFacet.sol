// SPDX-License-Identifier: AGPL-3.0-or-later
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  */

// Based on non-facet implementation by Aragon (https://github.com/aragon/osx/blob/develop/packages/contracts/src/core/plugin/proposal/Proposal.sol)

pragma solidity ^0.8.0;

/**
 * @title IBurnVotingProposalFacet
 * @author Utrecht University
 * @notice This facet allows proposal creation to cost tokens.
 */
interface IBurnVotingProposalFacet {
    function getProposalCreationCost() external view returns (uint256);

    function setProposalCreationCost(uint256 _proposalCreationCost) external;
}
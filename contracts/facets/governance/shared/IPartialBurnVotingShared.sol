// SPDX-License-Identifier: MIT
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  */

pragma solidity ^0.8.0;

// Shared permission between PartialBurnVotingProposalFacet and PartialBurnVotingFacet.
bytes32 constant PROPOSAL_BURN_TYPE =
    keccak256("burn.proposal.type.dg");
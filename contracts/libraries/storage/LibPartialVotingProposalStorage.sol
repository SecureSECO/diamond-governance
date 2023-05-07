// SPDX-License-Identifier: MIT
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  */

pragma solidity ^0.8.0;

import { IPartialVotingProposalFacet } from "../../facets/governance/proposal/IPartialVotingProposalFacet.sol";

library LibPartialVotingProposalStorage {
    bytes32 constant PARTIAL_VOTING_PROPOSAL_STORAGE_POSITION =
        keccak256("proposal.partialvoting.diamond.storage.position");

    struct Storage {
        /// @notice A mapping between proposal IDs and proposal information.
        mapping(uint256 => IPartialVotingProposalFacet.ProposalData) proposals;
        /// @notice The struct storing the voting settings.
        IPartialVotingProposalFacet.VotingSettings votingSettings;
    }

    function getStorage() internal pure returns (Storage storage ds) {
        bytes32 position = PARTIAL_VOTING_PROPOSAL_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IPartialVotingProposalFacet } from "../../facets/governance/proposal/IPartialVotingProposalFacet.sol";

library LibPartialVotingProposalStorage {
    bytes32 constant PARTIAL_VOTING_PROPOSAL_STORAGE_POSITION =
        keccak256("partial.voting.proposal.diamond.storage.position");

    struct PartialVotingProposalStorage {
        /// @notice A mapping between proposal IDs and proposal information.
        mapping(uint256 => IPartialVotingProposalFacet.ProposalData) proposals;
        /// @notice The struct storing the voting settings.
        IPartialVotingProposalFacet.VotingSettings votingSettings;
    }

    function partialVotingProposalStorage() internal pure returns (PartialVotingProposalStorage storage ds) {
        bytes32 position = PARTIAL_VOTING_PROPOSAL_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
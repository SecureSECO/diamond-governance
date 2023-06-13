// SPDX-License-Identifier: MIT
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  */
 
pragma solidity ^0.8.0;

library LibBurnVotingProposalStorage {
    bytes32 constant BURN_VOTING_PROPOSAL_STORAGE_POSITION =
        keccak256("proposal.burn.voting.diamond.storage.position");

    struct Storage {
        /// @notice Voting power that will be burned upon proposal creation.
        uint256 proposalCreationCost;
        /// @notice A mapping between proposal IDs and how much voting power a wallet has burned on this proposal.
        /// @dev Used for refunds when the proposal doesnt hit the participation threshold.
        mapping(uint256 => mapping(address => uint256)) proposalBurnData;
        /// @notice A mapping between proposal IDs and how much was paid to create it.
        /// @dev Used for refunding the proposal creator when the proposal passed.
        mapping(uint256 => uint256) proposalCost;
    }

    function getStorage() internal pure returns (Storage storage ds) {
        bytes32 position = BURN_VOTING_PROPOSAL_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
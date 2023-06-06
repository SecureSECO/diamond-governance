// SPDX-License-Identifier: AGPL-3.0-or-later
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  */


pragma solidity ^0.8.0;

import { IDAO } from "@aragon/osx/core/dao/IDAO.sol";

/// @title IPartialVoting
/// @author Utrecht University - 2023
/// @notice The interface of partial voting (voting) plugin.
/// @dev This contract implements the `IPartialVotingFacet` interface.
interface IPartialVotingFacet {
    /// @notice Vote options that a voter can chose from.
    /// @param Abstain This option does not influence the support but counts towards participation.
    /// @param Yes This option increases the support and counts towards participation.
    /// @param No This option decreases the support and counts towards participation.
    enum VoteOption {
        Abstain,
        Yes,
        No
    }

    struct PartialVote {
        VoteOption option;
        uint amount;
    }

    /// @notice Emitted when a vote is cast by a voter.
    /// @param proposalId The ID of the proposal.
    /// @param voter The voter casting the vote.
    /// @param voteData The casted vote option and the voting power behind this vote.
    event VoteCast(
        uint256 proposalId,
        address indexed voter,
        PartialVote voteData
    );

    enum VotingMode {
        SingleVote,
        SinglePartialVote,
        MultiplePartialVote
    }

    /// @notice Thrown if an account is not allowed to cast a vote. This can be because the vote
    /// - has not started,
    /// - has ended,
    /// - was executed, or
    /// - the account doesn't have the chosen voting power or more.
    /// @param proposalId The ID of the proposal.
    /// @param account The address of the _account.
    /// @param voteData The chosen vote option and chosen voting power.
    error VoteCastForbidden(uint256 proposalId, address account, PartialVote voteData);

    /// @notice Checks if an account can participate on a proposal vote. This can be because the vote
    /// - has not started,
    /// - has ended,
    /// - was executed, or
    /// - the voter doesn't have voting powers.
    /// @param _proposalId The proposal Id.
    /// @param _account The account address to be checked.
    /// @param  _voteData Whether the voter abstains, supports or opposes the proposal and how much voting power the voter would like to use.
    /// @return Returns true if the account is allowed to vote.
    /// @dev The function assumes the queried proposal exists.
    function canVote(
        uint256 _proposalId,
        address _account,
        PartialVote calldata _voteData
    ) external view returns (bool);

    /// @notice Votes for a vote option and, optionally, executes the proposal.
    /// @dev `_voteOption`, 1 -> abstain, 2 -> yes, 3 -> no
    /// @param _proposalId The ID of the proposal.
    /// @param _voteData The chosen vote option and the chosen amount of voting power to use.
    function vote(uint256 _proposalId, PartialVote calldata _voteData) external;
}
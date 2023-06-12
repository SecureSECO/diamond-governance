// SPDX-License-Identifier: AGPL-3.0-or-later
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  */


pragma solidity ^0.8.0;

import { IDAO } from "@aragon/osx/core/dao/IDAO.sol";

import { IPartialVotingFacet } from "../voting/IPartialVotingFacet.sol";

/// @title IPartialVoting
/// @author Utrecht University - 2023
/// @notice The interface of partial voting (voting) plugin.
/// @dev This contract implements the `IPartialVotingProposalFacet` interface.
interface IPartialVotingProposalFacet {
    /// @notice A container for the majority voting settings that will be applied as parameters on proposal creation.
    /// @param votingMode If users are allowed to vote partially and if so, if they are allowed to vote multiple times.
    /// @param supportThreshold The support threshold value. Its value has to be in the interval [0, 10^6] defined by `RATIO_BASE = 10**6`.
    /// @param minParticipation The minimum participation value. Its value has to be in the interval [0, 10^6] defined by `RATIO_BASE = 10**6`.
    /// @param maxSingleWalletPower The maximum voting power percentage usable by a single wallet on a single proposal. Its value has to be in the interval [0, 10^6] defined by `RATIO_BASE = 10**6`.
    /// @param minDuration The minimum duration of the proposal vote in seconds.
    /// @param minProposerVotingPower The minimum voting power required to create a proposal.
    struct VotingSettings {
        IPartialVotingFacet.VotingMode votingMode;
        uint32 supportThreshold;
        uint32 minParticipation;
        uint32 maxSingleWalletPower;
        uint64 minDuration;
        uint256 minProposerVotingPower;
    }

    /// @notice A container for proposal-related information.
    /// @param executed The block the proposal executed at, 0 for not executed.
    /// @param parameters The proposal parameters at the time of the proposal creation.
    /// @param tally The vote tally of the proposal.
    /// @param voters The votes casted by the voters.
    /// @param actions The actions to be executed when the proposal passes.
    /// @param allowFailureMap A bitmap allowing the proposal to succeed, even if individual actions might revert. If the bit at index `i` is 1, the proposal succeeds even if the `i`th action reverts. A failure map value of 0 requires every action to not revert.
    /// @param proposalType keccak256 of the proposal type, can be used by extensions to apply certain rules to proposal created in a certain way.
    /// @param metadata The IPFS hash of the metadata of the proposal.
    /// @param creator The address of the creator the proposal.
    /// @param voterList All the addresses that voted on this proposal.
    struct ProposalData {
        uint64 executed;
        ProposalParameters parameters;
        Tally tally;
        mapping(address => IPartialVotingFacet.PartialVote[]) voters;
        IDAO.Action[] actions;
        uint256 allowFailureMap;
        bytes32 proposalType;
        bytes metadata;
        address creator;
        address[] voterList;
        address executor;
    }

    /// @notice A container for the proposal parameters at the time of proposal creation.
    /// @param votingMode If users are allowed to vote partially and if so, if they are allowed to vote multiple times.
    /// @param earlyExecution If the vote is sure to pass, allow it to pass before the end of the proposal.
    /// @param supportThreshold The support threshold value. The value has to be in the interval [0, 10^6] defined by `RATIO_BASE = 10**6`.
    /// @param startDate The start date of the proposal vote.
    /// @param endDate The end date of the proposal vote.
    /// @param snapshotBlock The number of the block prior to the proposal creation.
    /// @param minParticipationThresholdPower The minimum total voting power needed for the proposal to hit the participation threshold.
    /// @param maxSingleWalletPower The maximum total voting power allowed to be used by a single wallet on this proposal.
    struct ProposalParameters {
        IPartialVotingFacet.VotingMode votingMode;
        bool earlyExecution;
        uint32 supportThreshold;
        uint64 startDate;
        uint64 endDate;
        uint64 snapshotBlock;
        uint256 minParticipationThresholdPower;
        uint256 maxSingleWalletPower;
    }

    /// @notice A container for the proposal vote tally.
    /// @param abstain The number of abstain votes casted.
    /// @param yes The number of yes votes casted.
    /// @param no The number of no votes casted.
    struct Tally {
        uint256 abstain;
        uint256 yes;
        uint256 no;
    }

    /// @notice Thrown if a date is out of bounds.
    /// @param limit The limit value.
    /// @param actual The actual value.
    error DateOutOfBounds(uint64 limit, uint64 actual);

    /// @notice Thrown if the minimal duration value is out of bounds (less than one hour or greater than 1 year).
    /// @param limit The limit value.
    /// @param actual The actual value.
    error MinDurationOutOfBounds(uint64 limit, uint64 actual);

    /// @notice Thrown when a sender is not allowed to create a proposal.
    /// @param sender The sender address.
    error ProposalCreationForbidden(address sender);

    /// @notice Thrown if the proposal execution is forbidden.
    /// @param proposalId The ID of the proposal.
    error ProposalExecutionForbidden(uint256 proposalId);

    /// @notice Emitted when the voting settings are updated.
    /// @param votingSettings The new voting settings.
    event VotingSettingsUpdated(VotingSettings votingSettings);

    /// @notice Returns the voting mode parameter stored in the voting settings.
    /// @return The voting mode parameter.
    function getVotingMode() external view returns (IPartialVotingFacet.VotingMode);

    /// @notice Change the voting mode parameter stored in the voting settings.
    function setVotingMode(IPartialVotingFacet.VotingMode _votingMode) external;

    /// @notice Returns the support threshold parameter stored in the voting settings.
    /// @return The support threshold parameter.
    function getSupportThreshold() external view returns (uint32);

    /// @notice Change the support threshold parameter stored in the voting settings.
    function setSupportThreshold(uint32 _supportThreshold) external;

    /// @notice Returns the minimum participation parameter stored in the voting settings.
    /// @return The minimum participation parameter.
    function getMinParticipation() external view returns (uint32);

    /// @notice Change the minimum participation parameter stored in the voting settings.
    function setMinParticipation(uint32 _minParticipation) external;

    /// @notice Returns the max single wallet power parameter stored in the voting settings.
    /// @return The max single wallet power parameter.
    function getMaxSingleWalletPower() external view returns (uint32);

    /// @notice Change the max single wallet power parameter stored in the voting settings.
    function setMaxSingleWalletPower(uint32 _maxSingleWalletPower) external;

    /// @notice Returns the minimum duration parameter stored in the voting settings.
    /// @return The minimum duration parameter.
    function getMinDuration() external view returns (uint64);

    /// @notice Change the minimum duration parameter stored in the voting settings.
    function setMinDuration(uint64 _minDuration) external;

    /// @notice Returns the minimum voting power required to create a proposal stored in the voting settings.
    /// @return The minimum voting power required to create a proposal.
    function getMinProposerVotingPower() external view returns (uint256);

    /// @notice Change the minimum voting power required to create a proposal stored in the voting settings.
    function setMinProposerVotingPower(uint256 _minProposerVotingPower) external;

    /// @notice Checks if the support value defined as $$\texttt{support} = \frac{N_\text{yes}}{N_\text{yes}+N_\text{no}}$$ for a proposal vote is greater than the support threshold.
    /// @param _proposalId The ID of the proposal.
    /// @return Returns `true` if the  support is greater than the support threshold and `false` otherwise.
    function isSupportThresholdReached(uint256 _proposalId) external view returns (bool);

    /// @notice Checks if the worst-case support value defined as $$\texttt{worstCaseSupport} = \frac{N_\text{yes}}{ N_\text{total}-N_\text{abstain}}$$ for a proposal vote is greater than the support threshold.
    /// @param _proposalId The ID of the proposal.
    /// @return Returns `true` if the worst-case support is greater than the support threshold and `false` otherwise.
    function isSupportThresholdReachedEarly(uint256 _proposalId) external view returns (bool);

    /// @notice Checks if the participation value defined as $$\texttt{participation} = \frac{N_\text{yes}+N_\text{no}+N_\text{abstain}}{N_\text{total}}$$ for a proposal vote is greater or equal than the minimum participation value.
    /// @param _proposalId The ID of the proposal.
    /// @return Returns `true` if the participation is greater than the minimum particpation and `false` otherwise.
    function isMinParticipationReached(uint256 _proposalId) external view returns (bool);

    /// @notice Checks if a proposal can be executed.
    /// @param _proposalId The ID of the proposal to be checked.
    /// @return True if the proposal can be executed, false otherwise.
    function canExecute(uint256 _proposalId) external view returns (bool);

    /// @notice Executes a proposal.
    /// @param _proposalId The ID of the proposal to be executed.
    function execute(uint256 _proposalId) external;

    /// @notice Returns whether the account has voted for the proposal.  Note, that this does not check if the account has voting power.
    /// @param _proposalId The ID of the proposal.
    /// @param _account The account address to be checked.
    /// @return The vote option cast by a voter for a certain proposal.
    function getVoteOption(
        uint256 _proposalId,
        address _account
    ) external view returns (IPartialVotingFacet.PartialVote[] calldata);

    /// @notice Retrieve the proposal data for a certain proposal.
    /// @dev This function is used by the frontend/sdk to display the proposal data.
    /// @param _proposalId The ID of the proposal.
    function getProposal(
        uint256 _proposalId
    ) external view returns (
            bool open,
            uint64 executed,
            ProposalParameters memory parameters,
            Tally memory tally,
            IDAO.Action[] memory actions,
            uint256 allowFailureMap,
            bytes memory metadata,
            address creator,
            address[] memory voterList,
            address executor
        );

    /// @notice Create a new proposal.
    /// @param _metadata The IPFS hash of the metadata of the proposal.
    /// @param _actions The actions to be executed when the proposal passes.
    /// @param _allowFailureMap A bitmap allowing the proposal to succeed, even if individual actions might revert.
    /// @param _startDate The start date of the proposal vote.
    /// @param _endDate The end date of the proposal vote.
    /// @param _allowEarlyExecution If the vote is sure to pass, allow it to pass before the end of the proposal.
    /// @return proposalId The ID of the newly created proposal.
    function createProposal(
        bytes calldata _metadata,
        IDAO.Action[] calldata _actions,
        uint256 _allowFailureMap,
        uint64 _startDate,
        uint64 _endDate,
        bool _allowEarlyExecution
    ) external returns (uint256 proposalId);
}
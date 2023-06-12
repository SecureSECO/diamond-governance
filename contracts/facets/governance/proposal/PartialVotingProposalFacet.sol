// SPDX-License-Identifier: AGPL-3.0-or-later
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  */


pragma solidity ^0.8.0;

import { SafeCast } from "@openzeppelin/contracts/utils/math/SafeCast.sol";
import { DaoAuthorizable } from "@aragon/osx/core/plugin/dao-authorizable/DaoAuthorizable.sol";

import { IPartialVotingProposalFacet, IPartialVotingFacet, IDAO } from "./IPartialVotingProposalFacet.sol";
import { IGovernanceStructure } from "../structure/voting-power/IGovernanceStructure.sol";
import "../../../utils/Ratio.sol";
import { IProposalFacet, IProposal } from "./IProposalFacet.sol";
import { AuthConsumer } from "../../../utils/AuthConsumer.sol";
import { IFacet } from "../../IFacet.sol";

import { LibPartialVotingProposalStorage } from "../../../libraries/storage/LibPartialVotingProposalStorage.sol";

/// @title PartialVotingProposalFacet
/// @author Utrecht University - 2023
/// @notice The partial implementation of partial voting proposal plugins.
/// @dev This contract implements the `IPartialVotingProposalFacet` interface.
contract PartialVotingProposalFacet is IPartialVotingProposalFacet, IProposalFacet, AuthConsumer
{
    using SafeCast for uint256;
    
    /// @notice The permission identifier to mint new tokens
    bytes32 public constant UPDATE_VOTING_SETTINGS_PERMISSION_ID = keccak256("UPDATE_VOTING_SETTINGS_PERMISSION");

    struct PartialVotingProposalFacetInitParams {
        IPartialVotingProposalFacet.VotingSettings votingSettings;
    }

    /// @inheritdoc IFacet
    function init(bytes memory initParams) public virtual override {
        PartialVotingProposalFacetInitParams memory _params = abi.decode(initParams, (PartialVotingProposalFacetInitParams));
        __PartialVotingProposalFacet_init(_params);
    }

    function __PartialVotingProposalFacet_init(PartialVotingProposalFacetInitParams memory _params) public virtual {
        LibPartialVotingProposalStorage.getStorage().votingSettings = _params.votingSettings;

        registerInterface(type(IPartialVotingProposalFacet).interfaceId);
        registerInterface(type(IProposal).interfaceId);
    }

    /// @inheritdoc IFacet
    function deinit() public virtual override {
        unregisterInterface(type(IPartialVotingProposalFacet).interfaceId);
        unregisterInterface(type(IProposal).interfaceId);
        super.deinit();
    }

    /// @inheritdoc IPartialVotingProposalFacet
    function execute(uint256 _proposalId) public virtual {
        if (!_canExecute(_proposalId)) {
            revert ProposalExecutionForbidden(_proposalId);
        }
        _execute(_proposalId, msg.sender);
    }

    /// @inheritdoc IPartialVotingProposalFacet
    function getVoteOption(
        uint256 _proposalId,
        address _voter
    ) public view virtual returns (IPartialVotingFacet.PartialVote[] memory) {
        return LibPartialVotingProposalStorage.getStorage().proposals[_proposalId].voters[_voter];
    }

    /// @inheritdoc IPartialVotingProposalFacet
    function canExecute(uint256 _proposalId) public view virtual returns (bool) {
        return _canExecute(_proposalId);
    }

    /// @inheritdoc IPartialVotingProposalFacet
    function isSupportThresholdReached(uint256 _proposalId) public view virtual returns (bool) {
        ProposalData storage proposal_ = LibPartialVotingProposalStorage.getStorage().proposals[_proposalId];

        // The code below implements the formula of the support criterion explained in the top of this file.
        // `(1 - supportThreshold) * N_yes > supportThreshold *  N_no`
        return
            (RATIO_BASE - proposal_.parameters.supportThreshold) * proposal_.tally.yes >
            proposal_.parameters.supportThreshold * proposal_.tally.no;
    }

    /// @inheritdoc IPartialVotingProposalFacet
    function isSupportThresholdReachedEarly(
        uint256 _proposalId
    ) public view virtual returns (bool) {
        ProposalData storage proposal_ = LibPartialVotingProposalStorage.getStorage().proposals[_proposalId];

        uint256 noVotesWorstCase = IGovernanceStructure(address(this)).totalVotingPower(proposal_.parameters.snapshotBlock) -
            proposal_.tally.yes;
            // Abstain is removed here, as this is increased with not used voting power on partial voting and can still be changed to no later

        // The code below implements the formula of the early execution support criterion explained in the top of this file.
        // `(1 - supportThreshold) * N_yes > supportThreshold *  N_no,worst-case`
        return
            (RATIO_BASE - proposal_.parameters.supportThreshold) * proposal_.tally.yes >
            proposal_.parameters.supportThreshold * noVotesWorstCase;
    }

    /// @inheritdoc IPartialVotingProposalFacet
    function isMinParticipationReached(uint256 _proposalId) public view virtual returns (bool) {
        ProposalData storage proposal_ = LibPartialVotingProposalStorage.getStorage().proposals[_proposalId];

        // The code below implements the formula of the participation criterion explained in the top of this file.
        // `N_yes + N_no + N_abstain >= minVotingPower = minParticipation * N_total`
        return
            proposal_.tally.yes + proposal_.tally.no + proposal_.tally.abstain >=
            proposal_.parameters.minParticipationThresholdPower;
    }
    
    /// @notice Returns the voting settings.
    /// @return The vote mode parameter.
    /// @inheritdoc IPartialVotingProposalFacet
    function getVotingMode() public view virtual returns (IPartialVotingFacet.VotingMode) {
        return LibPartialVotingProposalStorage.getStorage().votingSettings.votingMode;
    }

    /// @inheritdoc IPartialVotingProposalFacet
    function setVotingMode(IPartialVotingFacet.VotingMode _votingMode) external virtual auth(UPDATE_VOTING_SETTINGS_PERMISSION_ID) {
        LibPartialVotingProposalStorage.getStorage().votingSettings.votingMode = _votingMode;
        _updateVotingSettings();
    }

    /// @inheritdoc IPartialVotingProposalFacet
    function getSupportThreshold() public view virtual returns (uint32) {
        return LibPartialVotingProposalStorage.getStorage().votingSettings.supportThreshold;
    }

    /// @inheritdoc IPartialVotingProposalFacet
    function setSupportThreshold(uint32 _supportThreshold) external virtual auth(UPDATE_VOTING_SETTINGS_PERMISSION_ID) {
        // Require the support threshold value to be in the interval [0, 10^6-1], because `>` comparision is used in the support criterion and >100% could never be reached.
        if (_supportThreshold > RATIO_BASE - 1) {
            revert RatioOutOfBounds({limit: RATIO_BASE - 1, actual: _supportThreshold});
        }

        LibPartialVotingProposalStorage.getStorage().votingSettings.supportThreshold = _supportThreshold;
        _updateVotingSettings();
    }

    /// @inheritdoc IPartialVotingProposalFacet
    function getMinParticipation() public view virtual returns (uint32) {
        return LibPartialVotingProposalStorage.getStorage().votingSettings.minParticipation;
    }

    /// @inheritdoc IPartialVotingProposalFacet
    function setMinParticipation(uint32 _minParticipation) external virtual auth(UPDATE_VOTING_SETTINGS_PERMISSION_ID) {
        // Require the minimum participation value to be in the interval [0, 10^6], because `>=` comparision is used in the participation criterion.
        if (_minParticipation > RATIO_BASE) {
            revert RatioOutOfBounds({limit: RATIO_BASE, actual: _minParticipation});
        }

        LibPartialVotingProposalStorage.getStorage().votingSettings.minParticipation = _minParticipation;
        _updateVotingSettings();
    }

    /// @inheritdoc IPartialVotingProposalFacet
    function getMaxSingleWalletPower() public view virtual returns (uint32) {
        return LibPartialVotingProposalStorage.getStorage().votingSettings.maxSingleWalletPower;
    }

    /// @inheritdoc IPartialVotingProposalFacet
    function setMaxSingleWalletPower(uint32 _maxSingleWalletPower) external virtual auth(UPDATE_VOTING_SETTINGS_PERMISSION_ID) {
        // Require to be in the interval [0, 10^6]
        if (_maxSingleWalletPower > RATIO_BASE) {
            revert RatioOutOfBounds({limit: RATIO_BASE, actual: _maxSingleWalletPower});
        }
        LibPartialVotingProposalStorage.getStorage().votingSettings.maxSingleWalletPower = _maxSingleWalletPower;
        _updateVotingSettings();
    }

    /// @notice Returns the minimum duration parameter stored in the voting settings.
    /// @return The minimum duration parameter.
    /// @inheritdoc IPartialVotingProposalFacet
    function getMinDuration() public view virtual returns (uint64) {
        return LibPartialVotingProposalStorage.getStorage().votingSettings.minDuration;
    }

    /// @inheritdoc IPartialVotingProposalFacet
    function setMinDuration(uint64 _minDuration) external virtual auth(UPDATE_VOTING_SETTINGS_PERMISSION_ID) {
        LibPartialVotingProposalStorage.getStorage().votingSettings.minDuration = _minDuration;
        _updateVotingSettings();
    }

    /// @notice Returns the minimum voting power required to create a proposa stored in the voting settings.
    /// @return The minimum voting power required to create a proposal.
    /// @inheritdoc IPartialVotingProposalFacet
    function getMinProposerVotingPower() public view virtual returns (uint256) {
        return LibPartialVotingProposalStorage.getStorage().votingSettings.minProposerVotingPower;
    }

    /// @inheritdoc IPartialVotingProposalFacet
    function setMinProposerVotingPower(uint256 _minProposerVotingPower) external virtual auth(UPDATE_VOTING_SETTINGS_PERMISSION_ID) {
        LibPartialVotingProposalStorage.getStorage().votingSettings.minProposerVotingPower = _minProposerVotingPower;
        _updateVotingSettings();
    }
    
    /// @notice Internal function after voting settings have been updated
    function _updateVotingSettings() internal virtual {
        emit VotingSettingsUpdated(LibPartialVotingProposalStorage.getStorage().votingSettings);
    }

    /// @notice Returns all information for a proposal vote by its ID.
    /// @param _proposalId The ID of the proposal.
    /// @return open Whether the proposal is open or not.
    /// @return executed Whether the proposal is executed or not.
    /// @return parameters The parameters of the proposal vote.
    /// @return tally The current tally of the proposal vote.
    /// @return actions The actions to be executed in the associated DAO after the proposal has passed.
    /// @return allowFailureMap The bit map representations of which actions are allowed to revert so tx still succeeds.
    function getProposal(
        uint256 _proposalId
    )
        public
        view
        virtual
        returns (
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
        )
    {
        ProposalData storage proposal_ = LibPartialVotingProposalStorage.getStorage().proposals[_proposalId];

        open = _isProposalOpen(proposal_);
        executed = proposal_.executed;
        parameters = proposal_.parameters;
        tally = proposal_.tally;
        actions = proposal_.actions;
        allowFailureMap = proposal_.allowFailureMap;
        metadata = proposal_.metadata;
        creator = proposal_.creator;
        voterList = proposal_.voterList;
        executor = proposal_.executor;
    }

    /// @notice Creates a voting proposal.
    /// @return proposalId The ID of the proposal.
    function createProposal(
        bytes calldata _metadata,
        IDAO.Action[] calldata _actions,
        uint256 _allowFailureMap,
        uint64 _startDate,
        uint64 _endDate,
        bool _allowEarlyExecution
    ) external virtual returns (uint256 proposalId) {
        return _createProposal({
            _metadata: _metadata,
            _actions: _actions,
            _allowFailureMap: _allowFailureMap,
            _startDate: _startDate,
            _endDate: _endDate,
            _allowEarlyExecution: _allowEarlyExecution,
            _proposalType: bytes32(0)
        });
    }

    /// @notice Creates a voting proposal.
    /// @param _metadata The metadata of the proposal.
    /// @param _actions The actions that will be executed after the proposal passes.
    /// @param _allowFailureMap Allows proposal to succeed even if an action reverts. Uses bitmap representation. If the bit at index `x` is 1, the tx succeeds even if the action at `x` failed. Passing 0 will be treated as atomic execution.
    /// @param _startDate The start date of the proposal vote. If 0, the current timestamp is used and the vote starts immediately.
    /// @param _endDate The end date of the proposal vote. If 0, `_startDate + minDuration` is used.
    /// @param _allowEarlyExecution If `true`,  early execution is enabled for this proposal.
    /// @param _proposalType The type to give to this proposal.
    /// @return proposalId The ID of the proposal.
    function _createProposal(
        bytes calldata _metadata,
        IDAO.Action[] calldata _actions,
        uint256 _allowFailureMap,
        uint64 _startDate,
        uint64 _endDate,
        bool _allowEarlyExecution,
        bytes32 _proposalType
    ) internal virtual returns (uint256 proposalId) {
        uint256 snapshotBlock;
        unchecked {
            snapshotBlock = block.number - 1;
        }

        uint256 totalVotingPower_;
        // governance local variable only lives in the scope (max local variables reached)
        {
            IGovernanceStructure governance = IGovernanceStructure(address(this));
            totalVotingPower_ = governance.totalVotingPower(snapshotBlock);

            if (governance.walletVotingPower(msg.sender, snapshotBlock) < getMinProposerVotingPower()) {
                revert ProposalCreationForbidden(msg.sender);
            }
        }

        proposalId = _createProposal({
            _creator: msg.sender,
            _metadata: _metadata,
            _startDate: _startDate,
            _endDate: _endDate,
            _actions: _actions,
            _allowFailureMap: _allowFailureMap
        });

        // Store proposal related information
        ProposalData storage proposal_ = LibPartialVotingProposalStorage.getStorage().proposals[proposalId];

        proposal_.parameters.votingMode = getVotingMode();
        proposal_.parameters.earlyExecution = _allowEarlyExecution;
        (proposal_.parameters.startDate, proposal_.parameters.endDate) = _validateProposalDates(
            _startDate,
            _endDate
        );
        proposal_.parameters.snapshotBlock = snapshotBlock.toUint64();
        proposal_.parameters.supportThreshold = getSupportThreshold();
        proposal_.parameters.minParticipationThresholdPower = _applyRatioCeiled(
            totalVotingPower_,
            getMinParticipation()
        );
        proposal_.parameters.maxSingleWalletPower = _applyRatioCeiled(
            totalVotingPower_,
            getMaxSingleWalletPower()
        );
        proposal_.proposalType = _proposalType;
        proposal_.metadata = _metadata;
        proposal_.creator = msg.sender;

        // Reduce costs
        if (_allowFailureMap != 0) {
            proposal_.allowFailureMap = _allowFailureMap;
        }

        for (uint256 i; i < _actions.length; ) {
            proposal_.actions.push(_actions[i]);
            unchecked {
                ++i;
            }
        }
    }

    /// @notice Internal function to execute a vote. It assumes the queried proposal exists.
    /// @param _proposalId The ID of the proposal.
    function _execute(uint256 _proposalId, address _executor) internal virtual {
        ProposalData storage proposal_ = LibPartialVotingProposalStorage.getStorage().proposals[_proposalId];
        proposal_.executed = block.number.toUint64();
        proposal_.executor = _executor;

        _executeProposal(
            DaoAuthorizable(address(this)).dao(),
            _proposalId,
            proposal_.actions,
            proposal_.allowFailureMap
        );
    }

    /// @notice Internal function to check if a proposal can be executed. It assumes the queried proposal exists.
    /// @param _proposalId The ID of the proposal.
    /// @return True if the proposal can be executed, false otherwise.
    /// @dev Threshold and minimal values are compared with `>` and `>=` comparators, respectively.
    function _canExecute(uint256 _proposalId) internal view virtual returns (bool) {
        ProposalData storage proposal_ = LibPartialVotingProposalStorage.getStorage().proposals[_proposalId];

        // Verify that the vote has not been executed already.
        if (proposal_.executed > 0) {
            return false;
        }

        if (_isProposalOpen(proposal_)) {
            // Early execution
            if (!proposal_.parameters.earlyExecution) {
                return false;
            }
            if (!isSupportThresholdReachedEarly(_proposalId)) {
                return false;
            }
        } else {
            // Normal execution
            if (!isSupportThresholdReached(_proposalId)) {
                return false;
            }
        }
        if (!isMinParticipationReached(_proposalId)) {
            return false;
        }

        return true;
    }

    /// @notice Internal function to check if a proposal vote is still open.
    /// @param proposal_ The proposal struct.
    /// @return True if the proposal vote is open, false otherwise.
    function _isProposalOpen(ProposalData storage proposal_) internal view virtual returns (bool) {
        uint64 currentTime = block.timestamp.toUint64();

        return
            proposal_.parameters.startDate <= currentTime &&
            currentTime < proposal_.parameters.endDate &&
            proposal_.executed == 0;
    }

    /// @notice Validates and returns the proposal vote dates.
    /// @param _start The start date of the proposal vote. If 0, the current timestamp is used and the vote starts immediately.
    /// @param _end The end date of the proposal vote. If 0, `_start + minDuration` is used.
    /// @return startDate The validated start date of the proposal vote.
    /// @return endDate The validated end date of the proposal vote.
    function _validateProposalDates(
        uint64 _start,
        uint64 _end
    ) internal view virtual returns (uint64 startDate, uint64 endDate) {
        uint64 currentTimestamp = block.timestamp.toUint64();

        if (_start == 0) {
            startDate = currentTimestamp;
        } else {
            startDate = _start;

            if (startDate < currentTimestamp) {
                revert DateOutOfBounds({limit: currentTimestamp, actual: startDate});
            }
        }

        uint64 earliestEndDate = startDate + LibPartialVotingProposalStorage.getStorage().votingSettings.minDuration; // Since `minDuration` is limited to 1 year, `startDate + minDuration` can only overflow if the `startDate` is after `type(uint64).max - minDuration`. In this case, the proposal creation will revert and another date can be picked.

        if (_end == 0) {
            endDate = earliestEndDate;
        } else {
            endDate = _end;

            if (endDate < earliestEndDate) {
                revert DateOutOfBounds({limit: earliestEndDate, actual: endDate});
            }
        }
    }
}
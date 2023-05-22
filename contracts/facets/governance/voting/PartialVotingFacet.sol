// SPDX-License-Identifier: AGPL-3.0-or-later
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  */


pragma solidity ^0.8.0;

import { IPartialVotingFacet } from "./IPartialVotingFacet.sol";
import { IPartialVotingProposalFacet } from "../proposal/IPartialVotingProposalFacet.sol";
import { IGovernanceStructure } from "../structure/voting-power/IGovernanceStructure.sol";
import { AuthConsumer } from "../../../utils/AuthConsumer.sol";
import { IFacet } from "../../IFacet.sol";

import { LibPartialVotingProposalStorage } from "../../../libraries/storage/LibPartialVotingProposalStorage.sol";

/// @title PartialVotingFacet
/// @author Utrecht University - 2023
/// @notice The partial implementation of partial voting plugins.
/// @dev This contract implements the `IPartialVotingFacet` interface.
contract PartialVotingFacet is IPartialVotingFacet, AuthConsumer, IFacet {
    /// @inheritdoc IFacet
    function init(bytes memory/* _initParams*/) public virtual override {
        __PartialVotingFacet_init();
    }

    function __PartialVotingFacet_init() public virtual {
        registerInterface(type(IPartialVotingFacet).interfaceId);
    }

    /// @inheritdoc IFacet
    function deinit() public virtual override {
        unregisterInterface(type(IPartialVotingFacet).interfaceId);
        super.deinit();
    }

    /// @inheritdoc IPartialVotingFacet
    function vote(
        uint256 _proposalId,
        PartialVote calldata _voteData
    ) public virtual {
        address account = msg.sender;
        IPartialVotingProposalFacet.ProposalData storage proposal_ = LibPartialVotingProposalStorage.getStorage().proposals[_proposalId];

        if (!_canVote(_proposalId, proposal_, account, _voteData, IGovernanceStructure(address(this)))) {
            revert VoteCastForbidden({
                proposalId: _proposalId,
                account: account,
                voteData: _voteData
            });
        }
        _vote(_proposalId, proposal_, _voteData, account);
    }

    /// @inheritdoc IPartialVotingFacet
    function canVote(
        uint256 _proposalId,
        address _voter,
        PartialVote calldata _voteData
    ) public view virtual returns (bool) {
        return _canVote(_proposalId, LibPartialVotingProposalStorage.getStorage().proposals[_proposalId], _voter, _voteData, IGovernanceStructure(address(this)));
    }

    /// @notice Internal function to cast a vote. It assumes the queried vote exists.
    /// @param _proposalId The id of the proposal.
    /// @param _proposal The proposal.
    /// @param _voteData The chosen vote option and amount to be casted on the proposal vote.
    /// @param _voter The wallet that is voting.
    function _vote(
        uint256 _proposalId,
        IPartialVotingProposalFacet.ProposalData storage _proposal,
        PartialVote calldata _voteData,
        address _voter
    ) internal virtual {
        // Write the new vote for the voter.
        if (_voteData.option == VoteOption.Yes) {
            _proposal.tally.yes = _proposal.tally.yes + _voteData.amount;
        } else if (_voteData.option  == VoteOption.No) {
            _proposal.tally.no = _proposal.tally.no + _voteData.amount;
        } else if (_voteData.option  == VoteOption.Abstain) {
            _proposal.tally.abstain = _proposal.tally.abstain + _voteData.amount;
        }

        if (_proposal.voters[_voter].length == 0) {
            // New voter
            _proposal.voterList.push(_voter);
        }
        _proposal.voters[_voter].push(_voteData);
        
        emit VoteCast({
            proposalId: _proposalId,
            voter: _voter,
            voteData: _voteData
        });
    }

    /// @notice Internal function to check if a voter can vote. It assumes the queried proposal exists.
    /// @param _proposalId The id of the proposal.
    /// @param _proposal The proposal.
    /// @param _voter The address of the voter to check.
    /// @param  _voteData Whether the voter abstains, supports or opposes the proposal and with how much voting power.
    /// @return Returns `true` if the given voter can vote on a certain proposal and `false` otherwise.
    function _canVote(
        uint256 _proposalId,
        IPartialVotingProposalFacet.ProposalData storage _proposal,
        address _voter,
        PartialVote calldata _voteData,
        IGovernanceStructure _structure
    ) internal view virtual returns (bool) {
        // The proposal vote hasn't started or has already ended.
        (bool open,,,,,,,,,) = IPartialVotingProposalFacet(address(this)).getProposal(_proposalId);
        if (!open) {
            return false;
        }

        // The voter has already voted and the proposal only allows a single vote
        if (
            _proposal.voters[_voter].length > 0 &&
            (_proposal.parameters.votingMode == VotingMode.SingleVote ||
            _proposal.parameters.votingMode == VotingMode.SinglePartialVote)
        ) {
            return false;
        }

        uint256 votingPower = _structure.walletVotingPower(_voter, _proposal.parameters.snapshotBlock);

        // The voter has no voting power.
        if (votingPower == 0) {
            return false;
        }

        if (_proposal.parameters.votingMode == VotingMode.MultiplePartialVote) {
            uint alreadyUsedPower;
            for (uint i; i < _proposal.voters[_voter].length; ) {
                alreadyUsedPower += _proposal.voters[_voter][i].amount;
                unchecked {
                    i++;
                }
            }
            
            if (_voteData.amount + alreadyUsedPower > votingPower) {
                return false;
            }
        }
        else {
            // The voter is trying to vote with more voting power than they have avaliable.
            if (_voteData.amount > votingPower) {
                return false;
            }
        }

        // In partial vote the voter is not allowed to vote with more voting power than the maximum
        if (_voteData.amount > _proposal.parameters.maxSingleWalletPower &&
            _proposal.parameters.votingMode != VotingMode.SingleVote
        ) {
            return false;
        }

        // In single vote the voter is required to vote with all their voting power
        if (_voteData.amount < votingPower &&
            _proposal.parameters.votingMode == VotingMode.SingleVote
        ) {
            return false;
        }

        return true;
    }
}
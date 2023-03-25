// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.8.17;

import {SafeCastUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/math/SafeCastUpgradeable.sol";

import {IMembership} from "@aragon/osx/core/plugin/membership/IMembership.sol";
import {IDAO} from "@aragon/osx/core/dao/IDAO.sol";
import {_applyRatioCeiled} from "../../utils/Ratio.sol";
import {PartialVotingBase} from "../PartialVotingBase.sol";
import {IERC20BurnableVotesUpgradeable} from "../../token/IERC20BurnableVotesUpgradeable.sol";

/// @title PartialTokenBurnVoting
/// @author Utrecht University - 2023
/// @notice The partial token voting with burning implementation using an [OpenZepplin `Votes`](https://docs.openzeppelin.com/contracts/4.x/api/governance#Votes) compatible governance token.
/// @dev This contract inherits from `PartialVotingBase` and implements the `IMajorityVoting` interface.
/// @dev This contract is based on TokenVoting from Aragon
contract PartialTokenBurnVoting is IMembership, PartialVotingBase {
    using SafeCastUpgradeable for uint256;

    /// @notice The [ERC-165](https://eips.ethereum.org/EIPS/eip-165) interface ID of the contract.
    bytes4 internal constant TOKEN_VOTING_INTERFACE_ID =
        this.initialize.selector ^ this.getVotingToken.selector;

    /// @notice An [OpenZepplin `Votes`](https://docs.openzeppelin.com/contracts/4.x/api/governance#Votes) compatible contract referencing the token being used for voting and burning.
    IERC20BurnableVotesUpgradeable private votingToken;

    /// @notice Thrown if the voting power is zero
    error NoVotingPower();

    /// @notice Initializes the component.
    /// @dev This method is required to support [ERC-1822](https://eips.ethereum.org/EIPS/eip-1822).
    /// @param _dao The IDAO interface of the associated DAO.
    /// @param _votingSettings The voting settings.
    /// @param _token The [ERC-20](https://eips.ethereum.org/EIPS/eip-20) token used for voting.
    function initialize(
        IDAO _dao,
        VotingSettings calldata _votingSettings,
        IERC20BurnableVotesUpgradeable _token
    ) external initializer {
        __PartialVotingBase_init(_dao, _votingSettings);

        votingToken = _token;

        emit MembershipContractAnnounced({definingContract: address(_token)});
    }

    /// @notice Checks if this or the parent contract supports an interface by its ID.
    /// @param _interfaceId The ID of the interface.
    /// @return Returns `true` if the interface is supported.
    function supportsInterface(bytes4 _interfaceId) public view virtual override returns (bool) {
        return
            _interfaceId == TOKEN_VOTING_INTERFACE_ID ||
            _interfaceId == type(IMembership).interfaceId ||
            super.supportsInterface(_interfaceId);
    }

    /// @notice getter function for the voting token.
    /// @dev public function also useful for registering interfaceId and for distinguishing from majority voting interface.
    /// @return The token used for voting.
    function getVotingToken() public view returns (IERC20BurnableVotesUpgradeable) {
        return votingToken;
    }

    /// @inheritdoc PartialVotingBase
    function totalVotingPower(uint256 _blockNumber) public view override returns (uint256) {
        return votingToken.getPastTotalSupply(_blockNumber);
    }

    /// @inheritdoc PartialVotingBase
    function createProposal(
        bytes calldata _metadata,
        IDAO.Action[] calldata _actions,
        uint256 _allowFailureMap,
        uint64 _startDate,
        uint64 _endDate,
        PartialVote calldata _voteData,
        bool _tryEarlyExecution
    ) external override returns (uint256 proposalId) {
        uint256 snapshotBlock;
        unchecked {
            snapshotBlock = block.number - 1;
        }

        uint256 totalVotingPower_ = totalVotingPower(snapshotBlock);

        if (totalVotingPower_ == 0) {
            revert NoVotingPower();
        }

        if (votingToken.getPastVotes(_msgSender(), snapshotBlock) < minProposerVotingPower()) {
            revert ProposalCreationForbidden(_msgSender());
        }

        proposalId = _createProposal({
            _creator: _msgSender(),
            _metadata: _metadata,
            _startDate: _startDate,
            _endDate: _endDate,
            _actions: _actions,
            _allowFailureMap: _allowFailureMap
        });

        // Store proposal related information
        Proposal storage proposal_ = proposals[proposalId];

        (proposal_.parameters.startDate, proposal_.parameters.endDate) = _validateProposalDates(
            _startDate,
            _endDate
        );
        proposal_.parameters.snapshotBlock = snapshotBlock.toUint64();
        proposal_.parameters.votingMode = votingMode();
        proposal_.parameters.supportThreshold = supportThreshold();
        proposal_.parameters.minVotingPower = _applyRatioCeiled(
            totalVotingPower_,
            minParticipation()
        );

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

        vote(proposalId, _voteData, _tryEarlyExecution);
    }

    /// @inheritdoc IMembership
    function isMember(address _account) external view returns (bool) {
        /// TODO Add integration with GitHub and KYC checker contract
        return votingToken.getVotes(_account) > 0;
    }

    /// @inheritdoc PartialVotingBase
    function _vote(
        uint256 _proposalId,
        PartialVote calldata _voteData,
        address _voter,
        bool _tryEarlyExecution
    ) internal override {
        // Proposal storage proposal_ = proposals[_proposalId];

        // // Write the new vote for the voter.
        // if (_voteData.option == VoteOption.Yes) {
        //     proposal_.tally.yes = proposal_.tally.yes + _voteData.amount;
        // } else if (_voteData.option  == VoteOption.No) {
        //     proposal_.tally.no = proposal_.tally.no + _voteData.amount;
        // } else if (_voteData.option  == VoteOption.Abstain) {
        //     proposal_.tally.abstain = proposal_.tally.abstain + _voteData.amount;
        // }

        // proposal_.voters[_voter].push(_voteData);
        
        // if (proposal_.parameters.votingMode.burnTokens) {
        //     votingToken.burnFrom(_voter, _voteData.amount);
        // }

        // emit VoteCast({
        //     proposalId: _proposalId,
        //     voter: _voter,
        //     voteData: _voteData
        // });

        // if (_tryEarlyExecution && _canExecute(_proposalId)) {
        //     _execute(_proposalId);
        // }
    }

    /// @inheritdoc PartialVotingBase
    function _canVote(
        uint256 _proposalId,
        address _account,
        PartialVote calldata _voteData
    ) internal view override returns (bool) {
        Proposal storage proposal_ = proposals[_proposalId];

        // The proposal vote hasn't started or has already ended.
        if (!_isProposalOpen(proposal_)) {
            return false;
        }

        // The voter votes `None` which is not allowed.
        if (_voteData.option == VoteOption.None) {
            return false;
        }

        // The voter has already voted and the proposal only allows a single vote
        if (
            proposal_.voters[_account].length > 0 &&
            (proposal_.parameters.votingMode.partialVotingSettings == PartialVotingSettings.SingleVote ||
            proposal_.parameters.votingMode.partialVotingSettings == PartialVotingSettings.SinglePartialVote)
        ) {
            return false;
        }

        uint256 votingPower = votingToken.getPastVotes(_account, proposal_.parameters.snapshotBlock);

        // The voter has no voting power.
        if (votingPower == 0) {
            return false;
        }

        // The voter is trying to vote with more voting power than they have avaliable.
        if (_voteData.amount > votingPower) {
            return false;
        }

        // In single vote the voter is required to vote with all their voting power
        if (_voteData.amount < votingPower &&
            proposal_.parameters.votingMode.partialVotingSettings == PartialVotingSettings.SingleVote
        ) {
            return false;
        }

        // Trying to vote with more tokens than they have currently
        if (proposal_.parameters.votingMode.burnTokens &&
            _voteData.amount > votingToken.getVotes(_account)
        ) {
            return false;  
        }

        return true;
    }

    /// @dev This empty reserved space is put in place to allow future versions to add new
    /// variables without shifting down storage in the inheritance chain.
    /// https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
    uint256[49] private __gap;
}

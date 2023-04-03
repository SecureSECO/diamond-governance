// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { PartialVotingProposalFacet, IPartialVotingProposalFacet, IDAO } from "./PartialVotingProposalFacet.sol";
import "../shared/IPartialBurnVotingShared.sol";

contract PartialBurnVotingProposalFacet is PartialVotingProposalFacet {
    /// @inheritdoc PartialVotingProposalFacet
    function createProposal(
        bytes calldata _metadata,
        IDAO.Action[] calldata _actions,
        uint256 _allowFailureMap,
        uint64 _startDate,
        uint64 _endDate,
        bool _allowEarlyExecution
    ) external virtual override returns (uint256 proposalId) {
        proposalId = _createProposal({
            _metadata: _metadata,
            _actions: _actions,
            _allowFailureMap: _allowFailureMap,
            _startDate: _startDate,
            _endDate: _endDate,
            _allowEarlyExecution: _allowEarlyExecution,
            _proposalType: PROPOSAL_BURN_TYPE
        });
    }
}
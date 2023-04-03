// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { PartialVotingFacet, IPartialVotingProposalFacet, IGovernanceStructure, LibDiamond } from "./PartialVotingFacet.sol";
import { IBurnableGovernanceStructure } from "../structure/IBurnableGovernanceStructure.sol";
import "../shared/IPartialBurnVotingShared.sol";

contract PartialBurnVotingFacet is PartialVotingFacet {
    /// @inheritdoc PartialVotingFacet
    function _vote(
        IPartialVotingProposalFacet.ProposalData storage _proposal,
        PartialVote calldata _voteData,
        address _voter
    ) internal virtual override {
        super._vote(_proposal, _voteData, _voter);

        if (_proposal.proposalType == PROPOSAL_BURN_TYPE && 
            LibDiamond.diamondStorage().supportedInterfaces[type(IBurnableGovernanceStructure).interfaceId]
        ) {
            IBurnableGovernanceStructure(address(this)).burnVotingPower(_voter, _voteData.amount);
        }
    }
    
    /// @inheritdoc PartialVotingFacet
    function _canVote(
        uint256 _proposalId,
        IPartialVotingProposalFacet.ProposalData storage _proposal,
        address _voter,
        PartialVote calldata _voteData,
        IGovernanceStructure _structure
    ) internal view virtual override returns (bool) {
        // Trying to vote with more tokens than they have currently
        if (_proposal.proposalType == PROPOSAL_BURN_TYPE &&
            _voteData.amount > _structure.walletVotingPower(_voter, block.number - 1)
        ) {
            return false;
        }

        return super._canVote(_proposalId, _proposal, _voter, _voteData, _structure);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IMintableGovernanceStructure } from "../../../governance/structure/voting-power/IMintableGovernanceStructure.sol";
import { PartialVotingProposalFacet } from "../../../governance/proposal/PartialVotingProposalFacet.sol";

import { LibPartialBurnVotingProposalStorage } from "../../../../libraries/storage/LibPartialBurnVotingProposalStorage.sol";

contract ERC20PartialVoteBurningRefundFacet {
    function tokensRefundableFromProposal(uint256 _proposalId, address _claimer) public view virtual returns (uint256) {
        if (!_proposalRefundable(_proposalId)) return 0;

        return LibPartialBurnVotingProposalStorage.getStorage().proposalBurnData[_proposalId][_claimer];
    }

    function _proposalRefundable(uint256 _proposalId) internal view virtual returns (bool) {
        PartialVotingProposalFacet proposalFacet = PartialVotingProposalFacet(address(this));
        (bool open, , , , , ) = proposalFacet.getProposal(_proposalId);
        return !open && !proposalFacet.isMinParticipationReached(_proposalId);
    }

    function _afterClaim(uint256 _proposalId, address _claimer) internal virtual {
        LibPartialBurnVotingProposalStorage.getStorage().proposalBurnData[_proposalId][_claimer] = 0;
    }

    function refundTokensFromProposal(uint256 _proposalId) external virtual {
        IMintableGovernanceStructure(address(this)).mintVotingPower(msg.sender, 0, tokensRefundableFromProposal(_proposalId, msg.sender));
        _afterClaim(_proposalId, msg.sender);
    }
}
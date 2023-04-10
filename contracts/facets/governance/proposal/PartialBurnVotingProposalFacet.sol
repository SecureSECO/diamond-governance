// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { PartialVotingProposalFacet, IPartialVotingProposalFacet, IDAO, PartialVotingProposalFacetInit } from "./PartialVotingProposalFacet.sol";
import { IBurnableGovernanceStructure } from "../structure/voting-power/IBurnableGovernanceStructure.sol";
import "../shared/IPartialBurnVotingShared.sol";

import { LibPartialBurnVotingProposalStorage } from "../../../libraries/storage/LibPartialBurnVotingProposalStorage.sol";
import { LibDiamond } from "../../../libraries/LibDiamond.sol";

library PartialBurnVotingProposalFacetInit {
    struct InitParams {
        uint256 proposalCreationCost;
        PartialVotingProposalFacetInit.InitParams partialVotingProposalInit;
    }

    function init(InitParams calldata _params) external {
        LibPartialBurnVotingProposalStorage.getStorage().proposalCreationCost = _params.proposalCreationCost;
        PartialVotingProposalFacetInit.init(_params.partialVotingProposalInit);
    }
}

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

        // Check if the diamond supports burning
        if (LibDiamond.diamondStorage().supportedInterfaces[type(IBurnableGovernanceStructure).interfaceId]) {
            IBurnableGovernanceStructure(address(this)).burnVotingPower(msg.sender, LibPartialBurnVotingProposalStorage.getStorage().proposalCreationCost);
        }
    }
}
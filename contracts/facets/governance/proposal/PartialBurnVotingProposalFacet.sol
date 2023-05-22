// SPDX-License-Identifier: MIT
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  */

pragma solidity ^0.8.0;

import { PartialVotingProposalFacet, IPartialVotingProposalFacet, IDAO } from "./PartialVotingProposalFacet.sol";
import { IBurnVotingProposalFacet } from "./IBurnVotingProposalFacet.sol";
import { IBurnableGovernanceStructure } from "../structure/voting-power/IBurnableGovernanceStructure.sol";
import "../shared/IPartialBurnVotingShared.sol";

import { LibBurnVotingProposalStorage } from "../../../libraries/storage/LibBurnVotingProposalStorage.sol";
import { LibDiamond } from "../../../libraries/LibDiamond.sol";
import { IFacet } from "../../IFacet.sol";

contract PartialBurnVotingProposalFacet is PartialVotingProposalFacet, IBurnVotingProposalFacet {
    struct PartialBurnVotingProposalFacetInitParams {
        uint256 proposalCreationCost;
        PartialVotingProposalFacetInitParams _PartialVotingProposalFacetInitParams;
    }

    /// @inheritdoc IFacet
    function init(bytes memory initParams) public virtual override {
        PartialBurnVotingProposalFacetInitParams memory _params = abi.decode(initParams, (PartialBurnVotingProposalFacetInitParams));
        __PartialBurnVotingProposalFacet_init(_params);
    }

    function __PartialBurnVotingProposalFacet_init(PartialBurnVotingProposalFacetInitParams memory _params) public virtual {
        __PartialVotingProposalFacet_init(_params._PartialVotingProposalFacetInitParams);

        LibBurnVotingProposalStorage.getStorage().proposalCreationCost = _params.proposalCreationCost;

        registerInterface(type(IBurnVotingProposalFacet).interfaceId);
    }

    /// @inheritdoc IFacet
    function deinit() public virtual override {
        unregisterInterface(type(IBurnVotingProposalFacet).interfaceId);
        super.deinit();
    }

    /// @inheritdoc IBurnVotingProposalFacet
    function getProposalCreationCost() external view virtual returns (uint256) {
        return LibBurnVotingProposalStorage.getStorage().proposalCreationCost;
    }

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
            LibBurnVotingProposalStorage.Storage storage s = LibBurnVotingProposalStorage.getStorage();
            IBurnableGovernanceStructure(address(this)).burnVotingPower(msg.sender, s.proposalCreationCost);
            s.proposalCost[proposalId] = s.proposalCreationCost;
        }
    }
}
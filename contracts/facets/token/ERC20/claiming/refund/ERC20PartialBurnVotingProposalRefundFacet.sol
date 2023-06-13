// SPDX-License-Identifier: MIT
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  *
  * This source code is licensed under the MIT license found in the
  * LICENSE file in the root directory of this source tree.
  */
 
pragma solidity ^0.8.0;

import { IERC20PartialBurnVotingProposalRefundFacet } from "./IERC20PartialBurnVotingProposalRefundFacet.sol";
import { IMintableGovernanceStructure } from "../../../../governance/structure/voting-power/IMintableGovernanceStructure.sol";
import { IPartialVotingProposalFacet } from "../../../../governance/proposal/IPartialVotingProposalFacet.sol";

import { LibPartialVotingProposalStorage } from "../../../../../libraries/storage/LibPartialVotingProposalStorage.sol";
import { LibBurnVotingProposalStorage } from "../../../../../libraries/storage/LibBurnVotingProposalStorage.sol";
import { IFacet } from "../../../../IFacet.sol";

/**
 * @title ERC20PartialBurnVotingProposalRefundFacet
 * @author Utrecht University
 * @notice Implementation of IERC20PartialBurnVotingProposalRefundFacet.
 */
contract ERC20PartialBurnVotingProposalRefundFacet is IERC20PartialBurnVotingProposalRefundFacet, IFacet {
    /// @inheritdoc IFacet
    function init(bytes memory/* _initParams*/) public virtual override {
        __ERC20PartialBurnVotingProposalRefundFacet_init();
    }

    function __ERC20PartialBurnVotingProposalRefundFacet_init() public virtual {
        registerInterface(type(IERC20PartialBurnVotingProposalRefundFacet).interfaceId);
    }

    /// @inheritdoc IFacet
    function deinit() public virtual override {
        unregisterInterface(type(IERC20PartialBurnVotingProposalRefundFacet).interfaceId);
        super.deinit();
    }

    function tokensRefundableFromProposalCreation(uint256 _proposalId, address _claimer) public view virtual returns (uint256) {
        if (!_proposalRefundable(_proposalId)) return 0;
        if (_claimer != LibPartialVotingProposalStorage.getStorage().proposals[_proposalId].creator) return 0;

        return LibBurnVotingProposalStorage.getStorage().proposalCost[_proposalId];
    }

    function _proposalRefundable(uint256 _proposalId) internal view virtual returns (bool) {
        IPartialVotingProposalFacet proposalFacet = IPartialVotingProposalFacet(address(this));
        (bool open,,,,,,,,,) = proposalFacet.getProposal(_proposalId);
        return !open && proposalFacet.isSupportThresholdReached(_proposalId);
    }

    function _afterClaim(uint256 _proposalId, address/* _claimer*/) internal virtual {
        LibBurnVotingProposalStorage.getStorage().proposalCost[_proposalId] = 0;
    }

    function refundTokensFromProposalCreation(uint256 _proposalId) external virtual {
        IMintableGovernanceStructure(address(this)).mintVotingPower(msg.sender, 0, tokensRefundableFromProposalCreation(_proposalId, msg.sender));
        _afterClaim(_proposalId, msg.sender);
    }
}
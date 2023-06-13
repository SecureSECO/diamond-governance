// SPDX-License-Identifier: MIT
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  *
  * This source code is licensed under the MIT license found in the
  * LICENSE file in the root directory of this source tree.
  */
 
pragma solidity ^0.8.0;

import { IERC20PartialBurnVotingRefundFacet } from "./IERC20PartialBurnVotingRefundFacet.sol";
import { IMintableGovernanceStructure } from "../../../../governance/structure/voting-power/IMintableGovernanceStructure.sol";
import { IPartialVotingProposalFacet } from "../../../../governance/proposal/IPartialVotingProposalFacet.sol";

import { LibBurnVotingProposalStorage } from "../../../../../libraries/storage/LibBurnVotingProposalStorage.sol";
import { IFacet } from "../../../../IFacet.sol";

/**
 * @title ERC20PartialBurnVotingRefundFacet
 * @author Utrecht University
 * @notice Implementation of IERC20PartialBurnVotingRefundFacet.
 */
contract ERC20PartialBurnVotingRefundFacet is IERC20PartialBurnVotingRefundFacet, IFacet {
    /// @inheritdoc IFacet
    function init(bytes memory/* _initParams*/) public virtual override {
        __ERC20PartialBurnVotingRefundFacet_init();
    }

    function __ERC20PartialBurnVotingRefundFacet_init() public virtual {
        registerInterface(type(IERC20PartialBurnVotingRefundFacet).interfaceId);
    }

    /// @inheritdoc IFacet
    function deinit() public virtual override {
        unregisterInterface(type(IERC20PartialBurnVotingRefundFacet).interfaceId);
        super.deinit();
    }

    function tokensRefundableFromProposal(uint256 _proposalId, address _claimer) public view virtual returns (uint256) {
        if (!_proposalRefundable(_proposalId)) return 0;

        return LibBurnVotingProposalStorage.getStorage().proposalBurnData[_proposalId][_claimer];
    }

    function _proposalRefundable(uint256 _proposalId) internal view virtual returns (bool) {
        IPartialVotingProposalFacet proposalFacet = IPartialVotingProposalFacet(address(this));
        (bool open,,,,,,,,,) = proposalFacet.getProposal(_proposalId);
        return !open && !proposalFacet.isMinParticipationReached(_proposalId);
    }

    function _afterClaim(uint256 _proposalId, address _claimer) internal virtual {
        LibBurnVotingProposalStorage.getStorage().proposalBurnData[_proposalId][_claimer] = 0;
    }

    function refundTokensFromProposal(uint256 _proposalId) external virtual {
        IMintableGovernanceStructure(address(this)).mintVotingPower(msg.sender, 0, tokensRefundableFromProposal(_proposalId, msg.sender));
        _afterClaim(_proposalId, msg.sender);
    }
}
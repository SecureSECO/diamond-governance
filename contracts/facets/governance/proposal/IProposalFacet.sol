// SPDX-License-Identifier: AGPL-3.0-or-later
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  */

// Based on non-facet implementation by Aragon (https://github.com/aragon/osx/blob/develop/packages/contracts/src/core/plugin/proposal/Proposal.sol)

pragma solidity ^0.8.0;

import { Counters } from "@openzeppelin/contracts/utils/Counters.sol";
import { IProposal, IDAO } from "@aragon/osx/core/plugin/proposal/IProposal.sol";
import { IFacet } from "../../IFacet.sol";

import { LibProposalStorage } from "../../../libraries/storage/LibProposalStorage.sol";

/**
 * @title IProposalFacet
 * @author Utrecht University
 * @notice This facet keeps track of proposal count and provides the base to create and execute proposals.
 */
abstract contract IProposalFacet is IProposal, IFacet {
    using Counters for Counters.Counter;

    /// @inheritdoc IFacet
    function init(bytes memory initParams) public virtual override {
        registerInterface(type(IProposal).interfaceId);
        super.init(initParams);
    }

    /// @inheritdoc IProposal
    function proposalCount() public view override returns (uint256) {
        return LibProposalStorage.getStorage().proposalCounter.current();
    }

    /// @notice Creates a proposal ID.
    /// @return proposalId The proposal ID.
    function _createProposalId() internal returns (uint256 proposalId) {
        proposalId = proposalCount();
        LibProposalStorage.getStorage().proposalCounter.increment();
    }

    /// @notice Internal function to create a proposal.
    /// @param _metadata The the proposal metadata.
    /// @param _startDate The start date of the proposal in seconds.
    /// @param _endDate The end date of the proposal in seconds.
    /// @param _allowFailureMap A bitmap allowing the proposal to succeed, even if individual actions might revert. If the bit at index `i` is 1, the proposal succeeds even if the `i`th action reverts. A failure map value of 0 requires every action to not revert.
    /// @param _actions The actions that will be executed after the proposal passes.
    /// @return proposalId The ID of the proposal.
    function _createProposal(
        address _creator,
        bytes calldata _metadata,
        uint64 _startDate,
        uint64 _endDate,
        IDAO.Action[] calldata _actions,
        uint256 _allowFailureMap
    ) internal virtual returns (uint256 proposalId) {
        proposalId = _createProposalId();

        emit ProposalCreated({
            proposalId: proposalId,
            creator: _creator,
            metadata: _metadata,
            startDate: _startDate,
            endDate: _endDate,
            actions: _actions,
            allowFailureMap: _allowFailureMap
        });
    }

    /// @notice Internal function to execute a proposal.
    /// @param _proposalId The ID of the proposal to be executed.
    /// @param _actions The array of actions to be executed.
    /// @param _allowFailureMap A bitmap allowing the proposal to succeed, even if individual actions might revert. If the bit at index `i` is 1, the proposal succeeds even if the `i`th action reverts. A failure map value of 0 requires every action to not revert.
    /// @return execResults The array with the results of the executed actions.
    /// @return failureMap The failure map encoding which actions have failed.
    function _executeProposal(
        IDAO _dao,
        uint256 _proposalId,
        IDAO.Action[] memory _actions,
        uint256 _allowFailureMap
    ) internal virtual returns (bytes[] memory execResults, uint256 failureMap) {
        (execResults, failureMap) = _dao.execute(bytes32(_proposalId), _actions, _allowFailureMap);
        emit ProposalExecuted({proposalId: _proposalId});
    }
}
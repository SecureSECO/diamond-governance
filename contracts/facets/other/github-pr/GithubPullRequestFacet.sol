// SPDX-License-Identifier: MIT
/**
 * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
 * © Copyright Utrecht University (Department of Information and Computing Sciences)
 */

pragma solidity ^0.8.0;

import {IGithubPullRequestFacet} from "./IGitHubPullRequestFacet.sol";
import {AuthConsumer} from "../../../utils/AuthConsumer.sol";
import {IFacet} from "../../IFacet.sol";


/**
 * @title GithubPullRequestFacet
 * @author Utrecht University
 * @notice Implementation of IGithubPullRequestFacet.
 */
contract GithubPullRequestFacet is
    IGithubPullRequestFacet,
    AuthConsumer,
    IFacet
{
    /// @notice The permission identifier to merge pull requests.
    bytes32 public constant MERGE_PR_PERMISSION_ID =
        keccak256("MERGE_PR_PERMISSION");

    /// @inheritdoc IFacet
    function init(bytes memory /* _initParams*/) public virtual override {
        __GithubPullRequestFacet_init();
    }

    function __GithubPullRequestFacet_init() public virtual {
        registerInterface(type(IGithubPullRequestFacet).interfaceId);
    }

    /// @inheritdoc IFacet
    function deinit() public virtual override {
        unregisterInterface(type(IGithubPullRequestFacet).interfaceId);
        super.deinit();
    }

    /// Function that emits an event to merge a pull request
    /// @param _owner Owner of the repository
    /// @param _repo Name of the repository
    /// @param _pull_number Number of the pull request
    /// @param _sha SHA of the commit to merge
    function merge(
        string memory _owner,
        string memory _repo,
        string memory _pull_number,
        string memory _sha
    ) external virtual override auth(MERGE_PR_PERMISSION_ID) {
        emit MergePullRequest(_owner, _repo, _pull_number, _sha);
    }
}

// SPDX-License-Identifier: MIT
/**
 * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
 * © Copyright Utrecht University (Department of Information and Computing Sciences)
 */

pragma solidity ^0.8.0;

import { AuthConsumer } from "../../utils/AuthConsumer.sol";

contract GithubPullRequestFacet is AuthConsumer {

    /// @notice Emitted when a pull request needs to be merged as a result of a proposal action
    /// @param owner Owner of the repository
    /// @param repo Name of the repository
    /// @param pull_number Number of the pull request
    event MergePullRequest(string owner, string repo, string pull_number);

    /// @notice The permission identifier to merge pull requests.
    bytes32 public constant MERGE_PR_PERMISSION_ID = keccak256("MERGE_PR_PERMISSION");

    /// Function that emits an event to merge a pull request
    /// @param _owner Owner of the repository
    /// @param _repo Name of the repository
    /// @param _pull_number Number of the pull request
    function merge(string memory _owner, string memory _repo, string memory _pull_number) external auth(MERGE_PR_PERMISSION_ID) {
        emit MergePullRequest(_owner, _repo, _pull_number);
    }
}

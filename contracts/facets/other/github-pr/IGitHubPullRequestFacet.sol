// SPDX-License-Identifier: MIT
/**
 * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
 * © Copyright Utrecht University (Department of Information and Computing Sciences)
 */

pragma solidity ^0.8.0;

interface IGithubPullRequestFacet {
    /// @notice Emitted when a pull request needs to be merged as a result of a proposal action
    /// @param owner Owner of the repository
    /// @param repo Name of the repository
    /// @param pull_number Number of the pull request
    event MergePullRequest(
        string owner,
        string repo,
        string pull_number,
        string sha
    );

    function merge(
        string memory _owner,
        string memory _repo,
        string memory _pull_number,
        string memory _sha
    ) external;
}

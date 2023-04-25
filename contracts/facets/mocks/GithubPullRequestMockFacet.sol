// SPDX-License-Identifier: MIT
/**
 * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
 * © Copyright Utrecht University (Department of Information and Computing Sciences)
 */

pragma solidity ^0.8.0;

import { GithubPullRequestFacet } from "../github-pr/GithubPullRequestFacet.sol";

contract GithubPullRequestMockFacet {
    /// Mock function that calls the mergePullRequest function
    /// @param _owner owner of the repository
    /// @param _rep repository name
    /// @param _pull_number pull request number
    function _mergePullRequest(string memory _owner, string memory _rep, string memory _pull_number) external {
        GithubPullRequestFacet mergePullRequestFacet = GithubPullRequestFacet(address(this));
        mergePullRequestFacet.merge(_owner, _rep, _pull_number);
    }
}

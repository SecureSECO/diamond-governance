// SPDX-License-Identifier: MIT
/**
 * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
 * © Copyright Utrecht University (Department of Information and Computing Sciences)
 */

pragma solidity ^0.8.0;

import { GithubPullRequestFacet } from "./GithubPullRequestFacet.sol";

contract GithubPullRequestMockFacet {

    function _mergePullRequest(string memory _id) external {
        GithubPullRequestFacet mergePullRequestFacet = GithubPullRequestFacet(address(this));
        mergePullRequestFacet.mergePullRequest(_id);
    }
}

// SPDX-License-Identifier: MIT
/**
 * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
 * © Copyright Utrecht University (Department of Information and Computing Sciences)
 */

pragma solidity ^0.8.0;

import { AuthConsumer } from "../../utils/AuthConsumer.sol";

contract GithubPullRequestFacet is AuthConsumer {
    event MergePullRequest(string id);

    /// @notice The permission identifier to merge pull requests.
    bytes32 public constant MERGE_PR_PERMISSION_ID = keccak256("MERGE_PR_PERMISSION");

    function mergePullRequest(string memory _id) external auth(MERGE_PR_PERMISSION_ID) {
        emit MergePullRequest(_id);
    }
}

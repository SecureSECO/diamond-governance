// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IAuthProvider {
    function auth(bytes32 _permissionId) external;
}
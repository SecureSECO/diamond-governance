// SPDX-License-Identifier: MIT
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  */
pragma solidity ^0.8.0;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title PluginStandalone
 * @author Utrecht University
 * @notice This interface allows an Aragon plugin to be deployed as a standalone contract.
 */
abstract contract PluginStandalone is Ownable {
    address private dao_;
    mapping(bytes32 => mapping(address => bool)) private permissions_;
    
    error NotPermitted(bytes32 _permissionId);

    constructor() {
        dao_ = msg.sender;
    }

    function dao() public view returns (address) {
        return dao_;
    }

    function setDao(address _dao) external onlyOwner {
        dao_ = _dao;
    }

    function grantPermission(bytes32 _permissionId, address _to) external onlyOwner {
        permissions_[_permissionId][_to] = true;
    }
    
    function revokePermission(bytes32 _permissionId, address _to) external onlyOwner {
        permissions_[_permissionId][_to] = false;
    }

    modifier auth(bytes32 _permissionId) {
        if (!permissions_[_permissionId][msg.sender]) {
            revert NotPermitted(_permissionId);
        }
        _;
    }
}
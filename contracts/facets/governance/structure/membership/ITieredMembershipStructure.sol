// SPDX-License-Identifier: MIT
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  */

pragma solidity ^0.8.0;

import { IMembershipExtended, IMembership } from "./IMembershipExtended.sol";

/**
 * @title ITieredMembershipStructure
 * @author Utrecht University
 * @notice This interface extends IMembershipExtended, distinguishing members into tiers.
 */
abstract contract ITieredMembershipStructure is IMembershipExtended {
    /// @inheritdoc IMembershipExtended
    function isMember(address _account) external view virtual override returns (bool) {
        return _isMemberAt(_account, block.number);
    }

    /// @inheritdoc IMembershipExtended
    function isMemberAt(address _account, uint256 _blockNumber) external view override returns (bool) {
        return _isMemberAt(_account, _blockNumber);
    }

    /// @dev This internal copy is needed to be able to call the function from inside the contract
    /// This function is used by the isMember function given the latest block timestamp
    function _isMemberAt(address _account, uint256 _blockNumber) internal view virtual returns (bool) {
        return getTierAt(_account, _blockNumber) > 0;
    }

    /// @inheritdoc IMembershipExtended
    function getMembers() external view virtual override returns (address[] memory);

    /// @notice Returns the tier score for an accout at a given timestamp
    function getTierAt(address _account, uint256 _blockNumber) public view virtual returns (uint256);
}
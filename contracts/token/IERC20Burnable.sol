// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.8.17;

/// @title IERC20Burnable
/// @author Utrecht University - 2023
/// @notice An interface for burning burnable ERC20 tokens
abstract contract IERC20Burnable
{
    /// @dev Destroys `amount` tokens from `account`
    function burnFrom(address from, uint256 amount) public virtual returns (bool);
}
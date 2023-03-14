// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.8.17;

import {IVotesUpgradeable} from "@openzeppelin/contracts-upgradeable/governance/utils/IVotesUpgradeable.sol";

import {IERC20Burnable} from "./IERC20Burnable.sol";

/// @title IERC20BurnableVotesUpgradeable
/// @author Utrecht University - 2023
/// @notice A combination contract for `IERC20Burnable` and `IVotesUpgradeable` interfaces
abstract contract IERC20BurnableVotesUpgradeable is IERC20Burnable, IVotesUpgradeable
{
    
}
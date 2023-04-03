// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IGovernanceStructure } from "./IGovernanceStructure.sol";

interface IBurnableGovernanceStructure is IGovernanceStructure {
    /// @notice Burns an amount of voting power from a wallet.
    /// @param _from The wallet to burn from.
    /// @param _amount The amount of voting power to burn.
    function burnVotingPower(address _from, uint256 _amount) external;
}
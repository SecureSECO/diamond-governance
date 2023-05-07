// SPDX-License-Identifier: MIT
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  */

pragma solidity ^0.8.0;

import { GovernanceERC20Facet } from "./GovernanceERC20Facet.sol";
import { IBurnableGovernanceStructure } from "../../../governance/structure/voting-power/IBurnableGovernanceStructure.sol";

contract GovernanceERC20BurnableFacet is GovernanceERC20Facet, IBurnableGovernanceStructure {
    /// @notice The permission identifier to burn tokens (from any wallet)
    bytes32 public constant BURN_PERMISSION_ID = keccak256("BURN_PERMISSION");

    constructor(string memory name_, string memory symbol_) GovernanceERC20Facet(name_, symbol_) { }

    /// @inheritdoc IBurnableGovernanceStructure
    function burnVotingPower(address _wallet, uint256 _amount) external virtual override auth(BURN_PERMISSION_ID) {
        _burn(_wallet, _amount);
    }
}
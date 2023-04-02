// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { GovernanceERC20Facet } from "./GovernanceERC20Facet.sol";
import { IBurnableGovernanceStructure } from "../../../governance/structure/IBurnableGovernanceStructure.sol";

contract GovernanceERC20BurnableFacet is GovernanceERC20Facet, IBurnableGovernanceStructure {
    /// @notice The permission identifier to burn tokens (from any wallet)
    bytes32 public constant BURN_PERMISSION_ID = keccak256("BURN_PERMISSION");

    constructor(string memory name_, string memory symbol_) GovernanceERC20Facet(name_, symbol_) { }

    /// @inheritdoc IBurnableGovernanceStructure
    function burnVotingPower(address _wallet, uint256 _amount) external virtual override auth(BURN_PERMISSION_ID) {
        _burn(_wallet, _amount);
    }
}
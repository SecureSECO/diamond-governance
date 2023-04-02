// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { GovernanceERC20Facet, ERC20VotesFacet, ERC20PermitFacet, ERC20Facet } from "./GovernanceERC20Facet.sol";

contract GovernanceERC20DisabledFacet is GovernanceERC20Facet {
    constructor(string memory name_, string memory symbol_) GovernanceERC20Facet(name_, symbol_) { }

    /// @inheritdoc ERC20Facet
    function transfer(address/* to*/, uint256/* amount*/) public virtual override returns (bool) {
        revert("Disabled");
    }

    /// @inheritdoc ERC20Facet
    function approve(address/* spender*/, uint256/* amount*/) public virtual override returns (bool) {
        revert("Disabled");
    }

    /// @inheritdoc ERC20Facet
    function transferFrom(address/* from*/, address/* to*/, uint256/* amount*/) public virtual override returns (bool) {
        revert("Disabled");
    }

    /// @inheritdoc ERC20Facet
    function increaseAllowance(address/* spender*/, uint256/* addedValue*/) public virtual override returns (bool) {
        revert("Disabled");
    }

    /// @inheritdoc ERC20Facet
    function decreaseAllowance(address/* spender*/, uint256/* subtractedValue*/) public virtual override returns (bool) {
        revert("Disabled");
    }

    /// @inheritdoc ERC20PermitFacet
    function permit(
        address/* owner*/,
        address/* spender*/,
        uint256/* value*/,
        uint256/* deadline*/,
        uint8/* v*/,
        bytes32/* r*/,
        bytes32/* s*/
    ) public virtual override {
        revert("Disabled");
    }

    /// @inheritdoc ERC20VotesFacet
    function delegate(address/* delegatee*/) public virtual override {
        revert("Disabled");
    }

    /// @inheritdoc ERC20VotesFacet
    function delegateBySig(
        address/* delegatee*/,
        uint256/* nonce*/,
        uint256/* expiry*/,
        uint8/* v*/,
        bytes32/* r*/,
        bytes32/* s*/
    ) public virtual override {
        revert("Disabled");
    }
}
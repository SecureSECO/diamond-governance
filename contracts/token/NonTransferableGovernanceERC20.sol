// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.8.17;

import {GovernanceERC20} from "@aragon/osx/token/ERC20/governance/GovernanceERC20.sol";
import {IDAO} from "@aragon/osx/core/dao/IDAO.sol";

import {IERC20Burnable} from "./IERC20Burnable.sol";

/// @title NonTransferableGovernanceERC20
/// @author Utrecht University - 2023
/// @notice An [OpenZepplin `Votes`](https://docs.openzeppelin.com/contracts/4.x/api/governance#Votes) compatible [ERC-20](https://eips.ethereum.org/EIPS/eip-20) token that can be used for voting and is managed by a DAO.
/// @notice Cannot be transfered or delegated to other addresses
contract NonTransferableGovernanceERC20 is GovernanceERC20, IERC20Burnable
{
    /// @notice The permission identifier to transfer tokens (from any wallet)
    bytes32 public constant TRANSFER_PERMISSION_ID = keccak256("TRANSFER_PERMISSION");

    /// @notice The permission identifier to burn tokens (from any wallet)
    bytes32 public constant BURN_PERMISSION_ID = keccak256("BURN_PERMISSION");

    /// @notice Calls the initialize function.
    /// @param _dao The managing DAO.
    /// @param _name The name of the [ERC-20](https://eips.ethereum.org/EIPS/eip-20) governance token.
    /// @param _symbol The symbol fo the [ERC-20](https://eips.ethereum.org/EIPS/eip-20) governance token.
    /// @param _mintSettings The token mint settings struct containing the `receivers` and `amounts`.
    constructor(
        IDAO _dao,
        string memory _name,
        string memory _symbol,
        MintSettings memory _mintSettings
    ) GovernanceERC20(_dao, _name, _symbol, _mintSettings) {
        
    }

    function delegate(address/* delegatee*/) public virtual override {
        revert("Disabled");
    }

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

    function transfer(address/* to*/, uint256/* amount*/) public virtual override returns (bool) {
        revert("Disabled");
    }

    function transferFrom(address from, address to, uint256 amount) public virtual override auth(TRANSFER_PERMISSION_ID) returns (bool) {
        _transfer(from, to, amount);
        return true;
    }

    /// @inheritdoc IERC20Burnable
    function burnFrom(address from, uint256 amount) public virtual override auth(BURN_PERMISSION_ID) returns (bool) {
        _burn(from, amount);
        return true;
    } 
}
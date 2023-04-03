// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IGovernanceStructure } from "./IGovernanceStructure.sol";

interface IMintableGovernanceStructure is IGovernanceStructure {
    /// @notice Mints an amount of specific tokens to a wallet.
    /// @param _to The wallet to mint to.
    /// @param _tokenId The id of the token to mint (ERC721 / ERC1155).
    /// @param _amount The amount of tokens to mint (ERC20 / ERC1155).
    function mintVotingPower(address _to, uint256 _tokenId, uint256 _amount) external;
}
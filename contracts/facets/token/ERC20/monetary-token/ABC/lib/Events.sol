// SPDX-License-Identifier: MIT
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  */

// https://github.com/DAObox/liquid-protocol/blob/main/src/lib/Events.sol
pragma solidity >=0.8.17;

library Events {
    /**
     * @dev Emitted when tokens are minted continuously (the normal minting process).
     * @param buyer The address of the account that initiated the minting process.
     * @param minted The amount of tokens that were minted.
     * @param depositAmount The amount of ether that was deposited to mint the tokens.
     * @param fundingAmount The amount of ether that was sent to the owner as funding.
     */
    event ContinuousMint(address indexed buyer, uint256 minted, uint256 depositAmount, uint256 fundingAmount);

    /**
     * @dev Emitted when tokens are burned continuously (the normal burning process).
     * @param burner The address of the account that initiated the burning process.
     * @param burned The amount of tokens that were burned.
     * @param reimburseAmount The amount of ether that was reimbursed to the burner.
     * @param exitFee The amount of ether that was deducted as an exit fee.
     */
    event ContinuousBurn(address indexed burner, uint256 burned, uint256 reimburseAmount, uint256 exitFee);

    /**
     * @dev Emitted when tokens are minted in a sponsored process.
     * @param sender The address of the account that initiated the minting process.
     * @param depositAmount The amount of ether that was deposited to mint the tokens.
     * @param minted The amount of tokens that were minted.
     */
    event SponsoredMint(address indexed sender, uint256 depositAmount, uint256 minted);

    /**
     * @dev Emitted when tokens are burned in a sponsored process.
     * @param sender The address of the account that initiated the burning process.
     * @param burnAmount The amount of tokens that were burned.
     */
    event SponsoredBurn(address indexed sender, uint256 burnAmount);

    /**
     * @dev Emitted when the MarketMaker has been Hatched.
     * @param hatcher The address of the account recieved the hatch tokens.
     * @param amount The amount of bonded tokens that was minted to the hatcher.
     */
    event Hatch(address indexed hatcher, uint256 amount);
}
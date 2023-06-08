// SPDX-License-Identifier: MIT
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  */

// https://github.com/DAObox/liquid-protocol/blob/main/src/core/MarketMaker.sol
pragma solidity >=0.8.17;

import { SafeMath } from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { PluginStandalone } from "../standalone/PluginStandalone.sol";

import { IBondingCurve } from "../interfaces/IBondingCurve.sol";
import { IBondedToken } from "../interfaces/IBondedToken.sol";

import { Errors } from "../lib/Errors.sol";
import { Events } from "../lib/Events.sol";
import { Modifiers } from "../modifiers/MarketMaker.sol";
import { CurveParameters } from "../lib/Types.sol";

/**
 * @title DAO Market Maker with Adjustable Bonding Curve
 * @author DAOBox | (@pythonpete32)
 * @dev This contract is an non-upgradeable Aragon OSx Plugin
 *      It enables continuous minting and burning of tokens on an Augmented Bonding Curve, with part of the funds going
 * to the DAO and the rest being added to a reserve.
 *      The adjustable bonding curve formula is provided at initialization and determines the reward for minting and the
 * refund for burning.
 *      The DAO can also receive a sponsored mint, where another address pays to boost the reserve and the owner obtains
 * the minted tokens.
 *      Users can also perform a sponsored burn, where they burn their own tokens to enhance the value of the remaining
 * tokens.
 *      The DAO can set certain governance parameters like the theta (funding rate), or friction(exit fee)
 *
 * @notice This contract uses several external contracts and libraries from OpenZeppelin. Please review and understand
 * those before using this contract.
 * Also, consider the effects of the adjustable bonding curve and continuous minting/burning on your token's economics.
 * Use this contract responsibly.
 */
contract MarketMaker is PluginStandalone, Modifiers {
    using SafeMath for uint256;

    // =============================================================== //
    // ========================== CONSTANTS ========================== //
    // =============================================================== //

    /// @dev The identifier of the permission that allows an address to conduct the hatch.
    bytes32 public constant HATCH_PERMISSION_ID = keccak256("HATCH_PERMISSION");

    /// @dev The identifier of the permission that allows an address to configure the contract.
    bytes32 public constant CONFIGURE_PERMISSION_ID = keccak256("CONFIGURE_PERMISSION");

    /// @dev 100% represented in PPM (parts per million)
    uint32 public constant DENOMINATOR_PPM = 1_000_000;

    // =============================================================== //
    // =========================== STROAGE =========================== //
    // =============================================================== //

    /// @notice The bonded token
    IBondedToken private _bondedToken;

    /// @notice The external token used to purchase the bonded token
    IERC20 private _externalToken;

    /// @notice The parameters for the _curve
    CurveParameters private _curve;

    /// @notice is the contract post hatching
    bool private _hatched;

    // =============================================================== //
    // ========================= INITIALIZE ========================== //
    // =============================================================== //

    /**
     * @dev Sets the values for {owner}, {fundingRate}, {exitFee}, {reserveRatio}, {formula}, and {reserve}.
     * Governance cannot arbitrarily mint tokens after deployment. deployer must send some ETH
     * in the constructor to initialize the reserve.
     * Emits a {Transfer} event for the minted tokens.
     *
     * @param bondedToken_ The bonded token.
     * @param externalToken_ The external token used to purchace the bonded token.
     * @param curve_ The parameters for the curve_. This includes:
     *        {fundingRate} - The percentage of funds that go to the owner. Maximum value is 10000 (i.e., 100%).
     *        {exitFee} - The percentage of funds that are taken as fee when tokens are burned. Maximum value is 5000 (i.e., 50%).
     *        {reserveRatio} - The ratio for the reserve in the BancorBondingCurve.
     *        {formula} - The implementation of the bonding curve_.
     */
    constructor(
        IBondedToken bondedToken_,
        IERC20 externalToken_,
        CurveParameters memory curve_
    ) {
        _externalToken = externalToken_;
        _bondedToken = bondedToken_;
        _curve = curve_;
    }

    function hatch(
        uint256 initialSupply,
        address hatchTo
    )
        external
        preHatch(_hatched)
        auth(HATCH_PERMISSION_ID)
    {
        _hatched = true;

        // get the balance of the marketmaker and send theta to the DAO
        uint256 amount = _externalToken.balanceOf(address(this));

        // validate there is Liquidity to hatch with
        if (amount == 0) revert Errors.InitialReserveCannotBeZero();

        uint256 theta = calculateFee(amount); // Calculate the funding amount
        _externalToken.transfer(dao(), theta);

        // mint the hatched tokens to the hatcher
        if (hatchTo != address(0)) _bondedToken.mint(hatchTo, initialSupply);
        emit Events.Hatch(hatchTo, hatchTo == address(0) ? 0 : initialSupply);

        // this event parameters are not consistent and confusing, change them
        emit Events.ContinuousMint(hatchTo, initialSupply, amount, theta);
    }

    // =============================================================== //
    // ======================== BONDING CURVE ======================== //
    // =============================================================== //

    /**
     * @dev Mints tokens continuously, adding a portion of the minted amount to the reserve.
     * Reverts if the sender is the contract owner or if no ether is sent.
     * Emits a {ContinuousMint} event.
     * @param _amount The amount of external tokens used to mint.
     * @param _minAmountReceived The amount of bonded tokens to receive at least, otherwise the transaction will be reverted.
     */
    function mint(uint256 _amount, uint256 _minAmountReceived) public isDepositZero(_amount) postHatch(_hatched) {
        if (msg.sender == dao())
            revert Errors.OwnerCanNotContinuousMint();

        // Calculate the reward amount and mint the tokens
        uint256 rewardAmount = calculateMint(_amount); // Calculate the reward amount

        _externalToken.transferFrom(msg.sender, address(this), _amount);

        // Calculate the funding portion and the reserve portion
        uint256 fundingAmount = calculateFee(_amount); // Calculate the funding amount

        // transfer the funding amount to the funding pool
        // could the DAO reenter? 🧐
        _externalToken.transfer(dao(), fundingAmount);

        if (rewardAmount < _minAmountReceived)
            revert Errors.WouldRecieveLessThanMinRecieve();
        // Mint the tokens to the sender
        // but this is being called with static call
        _bondedToken.mint(msg.sender, rewardAmount);

        // Emit the ContinuousMint event
        emit Events.ContinuousMint(msg.sender, rewardAmount, _amount, fundingAmount);
    }

    /**
     * @dev Burns tokens continuously, deducting a portion of the burned amount from the reserve.
     * Reverts if the sender is the contract owner, if no tokens are burned, if the sender's balance is insufficient,
     * or if the reserve is insufficient to cover the refund amount.
     * Emits a {ContinuousBurn} event.
     *
     * @param _amount The amount of tokens to burn.
     * @param _minAmountReceived The amount of bonded tokens to receive at least, otherwise the transaction will be reverted.
     */
    function burn(uint256 _amount, uint256 _minAmountReceived) public isDepositZero(_amount) postHatch(_hatched) {
        if (msg.sender == dao())
            revert Errors.OwnerCanNotContinuousBurn();

        // Calculate the refund amount
        uint256 refundAmount = calculateBurn(_amount);

        _bondedToken.burn(msg.sender, _amount);

        // Calculate the exit fee
        uint256 exitFeeAmount = calculateFee(refundAmount);

        // Calculate the refund amount minus the exit fee
        uint256 refundAmountLessFee = refundAmount - exitFeeAmount;

        if (refundAmountLessFee < _minAmountReceived)
            revert Errors.WouldRecieveLessThanMinRecieve();
        // transfer the refund amount minus the exit fee to the sender
        _externalToken.transfer(msg.sender, refundAmountLessFee);

        // Emit the ContinuousBurn event
        emit Events.ContinuousBurn(msg.sender, _amount, refundAmountLessFee, exitFeeAmount);
    }

    /**
     * @notice Mints tokens to the owner's address and adds the sent ether to the reserve.
     * @dev This function is referred to as "sponsored" mint because the sender of the transaction sponsors
     * the increase of the reserve but the minted tokens are sent to the owner of the contract. This can be
     * useful in scenarios where a third-party entity (e.g., a user, an investor, or another contract) wants
     * to increase the reserve and, indirectly, the value of the token, without receiving any tokens in return.
     * The function reverts if no ether is sent along with the transaction.
     * Emits a {SponsoredMint} event.
     * @return mintedTokens The amount of tokens minted to the owner's address.
     */
    function sponsoredMint(uint256 _amount)
        external
        payable
        isDepositZero(_amount)
        postHatch(_hatched)
        returns (uint256)
    {
        // Transfer the specified amount of tokens from the sender to the contract
        _externalToken.transferFrom(msg.sender, address(this), _amount);

        // Calculate the number of tokens to be minted based on the deposited amount
        uint256 mintedTokens = calculateMint(_amount);

        // Mint the calculated amount of tokens to the owner's address
        _bondedToken.mint(address(dao()), mintedTokens);

        // Emit the SponsoredMint event, which logs the details of the minting transaction
        emit Events.SponsoredMint(msg.sender, _amount, mintedTokens);

        // Return the amount of tokens minted
        return mintedTokens;
    }

    /**
     * @notice Burns a specific amount of tokens from the caller's balance.
     * @dev This function is referred to as "sponsored" burn because the caller of the function burns
     * their own tokens, effectively reducing the total supply and, indirectly, increasing the value of
     * remaining tokens. The function reverts if the caller tries to burn more tokens than their balance
     * or tries to burn zero tokens. Emits a {SponsoredBurn} event.
     * @param _amount The amount of tokens to burn.
     */
    function sponsoredBurn(uint256 _amount) external isDepositZero(_amount) postHatch(_hatched) {
        // Burn the specified amount of tokens from the caller's balance
        _bondedToken.burn(msg.sender, _amount);

        // Emit the SponsoredBurn event, which logs the details of the burn transaction
        emit Events.SponsoredBurn(msg.sender, _amount);
    }

    // =============================================================== //
    // ===================== GOVERNANCE FUNCTIONS ==================== //
    // =============================================================== //

    /**
     * @notice Set governance parameters.
     * @dev Allows the owner to modify the funding rate, exit fee, or owner address of the contract.
     * The value parameter is a bytes type and should be decoded to the appropriate type based on
     * the parameter being modified.
     * @param what The name of the governance parameter to modify
     * @param value The new value for the specified governance parameter.
     * Must be ABI-encoded before passing it to the function.
     */
    function setGovernance(bytes32 what, bytes memory value) external auth(CONFIGURE_PERMISSION_ID) {
        if (what == "theta") _curve.theta = (abi.decode(value, (uint32)));
        else if (what == "friction") _curve.friction = (abi.decode(value, (uint32)));
        else if (what == "reserveRatio") _curve.reserveRatio = (abi.decode(value, (uint32)));
        else if (what == "formula") _curve.formula = (abi.decode(value, (IBondingCurve)));
        else revert Errors.InvalidGovernanceParameter(what);
    }

    // =============================================================== //
    // ======================== VIEW FUNCTIONS ======================= //
    // =============================================================== //

    /**
     * @notice Calculates and returns the amount of tokens that can be minted with {_amount}.
     * @dev The price calculation is based on the current bonding _curve and reserve ratio.
     * @return uint The amount of tokens that can be minted with {_amount}.
     */
    function calculateMint(uint256 _amount) public view returns (uint256) {
        return _curve.formula.getContinuousMintReward({
            depositAmount: _amount,
            continuousSupply: totalSupply() + _amount - calculateFee(_amount),
            reserveBalance: reserveBalance(),
            reserveRatio: reserveRatio()
        });
    }

    function calculateMintReverse(uint256 _toRecieve) external view returns (uint256) {
        return calculateBurn(_toRecieve);
    }

    /**
     * @notice Calculates and returns the amount of Ether that can be refunded by burning {_amount} Continuous
     * Governance Token.
     * @dev The price calculation is based on the current bonding _curve and reserve ratio.
     * @return uint The amount of Ether that can be refunded by burning {_amount} token.
     */
    function calculateBurn(uint256 _amount) public view returns (uint256) {
        return _curve.formula.getContinuousBurnRefund(_amount, totalSupply() - _amount, reserveBalance(), reserveRatio());
    }

    function calculateFee(uint256 _burnAmount) public view returns (uint256) {
        return (_burnAmount * _curve.friction) / DENOMINATOR_PPM;
    }

    /**
     * @notice Returns the current implementation of the bonding _curve used by the contract.
     * @dev This is an internal property and cannot be modified directly. Use the appropriate function to modify it.
     * @return The current implementation of the bonding _curve.
     */
    function getCurveParameters() public view returns (CurveParameters memory) {
        return _curve;
    }

    /**
     * @notice Returns the current reserve balance of the contract.
     * @dev This function is necessary to calculate the buy and sell price of the tokens. The reserve
     * balance represents the amount of ether held by the contract, and is used in the Bancor algorithm
     *  to determine the price _curve of the token.
     * @return The current reserve balance of the contract.
     */
    function reserveBalance() public view returns (uint256) {
        return _externalToken.balanceOf(address(this));
    }

    function totalSupply() public view returns (uint256) {
        return _bondedToken.totalSupply();
    }

    function externalToken() public view returns (IERC20) {
        return _externalToken;
    }

    function bondedToken() public view returns (IBondedToken) {
        return _bondedToken;
    }

    function isHatched() public view returns (bool) {
        return _hatched;
    }

    function reserveRatio() public view returns (uint32) {
        return _curve.reserveRatio;
    }
}
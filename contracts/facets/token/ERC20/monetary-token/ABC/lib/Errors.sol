// SPDX-License-Identifier: MIT
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  */

// https://github.com/DAObox/liquid-protocol/blob/main/src/lib/Errors.sol
pragma solidity >=0.8.17;

library Errors {
    /// @notice Error thrown when the market is already open
    error TradingAlreadyOpened();

    /// @notice Error thrown when the initial reserve for the token contract is zero.
    error InitialReserveCannotBeZero();

    /// @notice Error thrown when the funding rate provided is greater than 10000 (100%).
    /// @param fundingRate The value of the funding rate provided.
    error FundingRateError(uint16 fundingRate);

    /// @notice Error thrown when the exit fee provided is greater than 5000 (50%).
    /// @param exitFee The value of the exit fee provided.
    error ExitFeeError(uint16 exitFee);

    /// @notice Error thrown when the initial supply for the token contract is zero.
    error InitialSupplyCannotBeZero();
    
    /// @notice Error thrown when the funding amount for the token contract is higher than it's balance.
    error FundingAmountHigherThanBalance();

    /// @notice Error thrown when the owner of the contract tries to mint tokens continuously.
    error OwnerCanNotContinuousMint();

    /// @notice Error thrown when the owner of the contract tries to burn tokens continuously.
    error OwnerCanNotContinuousBurn();

    /// @notice Error thrown when the deposit amount provided is zero.
    error DepositAmountCannotBeZero();

    /// @notice Error thrown when the burn amount provided is zero.
    error BurnAmountCannotBeZero();

    /// @notice Error thrown when the reserve balance is less than the amount requested to burn.
    /// @param requested The amount of tokens requested to burn.
    /// @param available The available balance in the reserve.
    error InsufficientReserve(uint256 requested, uint256 available);

    /// @notice Error thrown when the balance of the sender is less than the amount requested to burn.
    /// @param sender The address of the sender.
    /// @param balance The balance of the sender.
    /// @param amount The amount requested to burn.
    error InsufficentBalance(address sender, uint256 balance, uint256 amount);

    /// @notice Error thrown when a function that requires ownership is called by an address other than the owner.
    /// @param caller The address of the caller.
    /// @param owner The address of the owner.
    error OnlyOwner(address caller, address owner);

    /// @notice Error thrown when a transfer of ether fails.
    /// @param recipient The address of the recipient.
    /// @param amount The amount of ether to transfer.
    error TransferFailed(address recipient, uint256 amount);

    /// @notice Error thrown when an invalid governance parameter is set.
    /// @param what The invalid governance parameter.
    error InvalidGovernanceParameter(bytes32 what);

    /// @notice Error thrown when addresses and values provided are not equal.
    /// @param addresses The number of addresses provided.
    /// @param values The number of values provided.
    error AddressesAmountMismatch(uint256 addresses, uint256 values);

    error AddressCannotBeZero();

    error InvalidPPMValue(uint32 value);

    error HatchingNotStarted();

    error HatchingAlreadyStarted();

    error HatchNotOpen();

    error VestingScheduleNotInitialized();

    error VestingScheduleRevoked();

    error VestingScheduleNotRevocable();

    error OnlyBeneficiary(address caller, address beneficiary);

    error NotEnoughVestedTokens(uint256 requested, uint256 available);

    error DurationCannotBeZero();

    error SlicePeriodCannotBeZero();

    error DurationCannotBeLessThanCliff();

    error ContributionWindowClosed();

    error MaxContributionReached();

    error HatchNotCanceled();

    error NoContribution();

    error NotEnoughRaised();

    error HatchOngoing();

    error MinRaiseMet();
}
// SPDX-License-Identifier: MIT
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  */

// https://github.com/DAObox/liquid-protocol/blob/main/src/modifiers/Vesting.sol
pragma solidity >=0.8.17;

import { Errors } from "../lib/Errors.sol";
import { VestingState } from "../lib/Types.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

abstract contract Modifiers {
    /**
     * @dev This modifier checks if the vesting schedule is not revoked.
     *      It reverts if the vesting schedule is revoked.
     */
    modifier onlyIfVestingScheduleNotRevoked(VestingState memory state) {
        if (state.revoked) revert Errors.VestingScheduleRevoked();
        _;
    }

    /**
     * @dev This modifier checks if the caller is the owner and if the vesting schedule is revocable and not already
     * revoked.
     *      It reverts if the caller is not the owner, the vesting schedule is not revocable, or the vesting schedule is
     * already revoked.
     *
     * @param state The vesting state
     * @param owner The owner's address
     */
    modifier validateRevoke(VestingState memory state, address owner) {
        if (msg.sender != owner) revert Errors.OnlyOwner(msg.sender, owner);
        if (!state.schedule.revocable) revert Errors.VestingScheduleNotRevocable();
        if (state.revoked) revert Errors.VestingScheduleRevoked();
        _;
    }

    /**
     * @dev This modifier checks if the caller is the beneficiary.
     *      It reverts if the caller is not the beneficiary.
     *
     * @param beneficiary The beneficiary's address
     */
    modifier onlyBeneficiary(address beneficiary) {
        if (msg.sender != beneficiary) revert Errors.OnlyBeneficiary(msg.sender, beneficiary);
        _;
    }

    /**
     * @dev This modifier checks if the vesting schedule is not revoked, and if the requested amount is
     * less than or equal to the releasable amount.
     *      It reverts if the vesting schedule is not initialized or revoked, or if the requested amount is greater than
     * the releasable amount.
     *
     * @param requested The requested amount
     * @param releasable The releasable amount
     * @param state The vesting state
     */
    modifier validateRelease(uint256 requested, uint256 releasable, VestingState memory state) {
        if (state.revoked) revert Errors.VestingScheduleRevoked();
        if (requested > releasable) {
            revert Errors.NotEnoughVestedTokens({ requested: requested, available: releasable });
        }
        _;
    }

    /**
     * @dev This modifier checks if the beneficiary and token addresses are not the zero address,
     *      if the duration and slice period of the vesting schedule are not zero,
     *      if the duration is not less than the cliff,
     *      if the total amount of the vesting schedule is not greater than the token balance of this contract.
     *      It reverts if any of these conditions are not met.
     *
     * @param beneficiary The beneficiary's address
     * @param token The token's address
     * @param state The vesting state
     */
    modifier validateInitialize(address beneficiary, IERC20 token, VestingState memory state) {
        if (state.schedule.duration == 0) revert Errors.DurationCannotBeZero();
        if (state.schedule.slicePeriodSeconds == 0) revert Errors.SlicePeriodCannotBeZero();
        if (state.schedule.duration < state.schedule.cliff) revert Errors.DurationCannotBeLessThanCliff();
        if (state.amountTotal > token.balanceOf(address(this))) {
            revert Errors.InsufficientReserve({
                requested: state.amountTotal,
                available: token.balanceOf(address(this))
            });
        }
        _;
    }
}
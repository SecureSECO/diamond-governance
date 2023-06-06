// SPDX-License-Identifier: MIT
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  */

// https://github.com/DAObox/liquid-protocol/blob/main/src/core/Vesting.sol
pragma solidity >= 0.8.17;

// OpenZeppelin dependencies
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IVotes } from "@openzeppelin/contracts/governance/utils/IVotes.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import { Errors } from "../lib/Errors.sol";
import { VestingState, VestingSchedule } from "../lib/Types.sol";
import { Modifiers } from "../modifiers/Vesting.sol";

/**
 * @title Vesting
 * @author DAOBox | (@pythonpete32)
 * @dev This contract enables vesting of tokens over a certain period of time. It is upgradeable and protected against
 * reentrancy attacks.
 *      The contract allows an admin to initialize the vesting schedule and the beneficiary of the vested tokens. Once
 * the vesting starts, the beneficiary
 *      can claim the releasable tokens at any time. If the vesting is revocable, the admin can revoke the remaining
 * tokens and send them to a specified address.
 *      The beneficiary can also delegate their voting power to another address.
 */
contract Vesting is ReentrancyGuard, Modifiers {
    /// @notice The token being vested
    IERC20 private _token;

    /// @notice The vesting state
    VestingState private _state;

    /// @notice The beneficiary of the vested tokens
    address private _beneficiary;

    /// @notice The admin address
    address private _admin;

    /**
     * @dev Initializes the vesting contract with the provided parameters.
     *      The admin, beneficiary, token, and vesting schedule are all set during initialization.
     *      Additionally, voting power for the vested tokens is delegated to the beneficiary.
     *
     * @param admin_ The address of the admin
     * @param beneficiary_ The address of the beneficiary
     * @param token_ The address of the token
     * @param schedule_ The vesting schedule
     */
    constructor(
        address admin_,
        address beneficiary_,
        IERC20 token_,
        VestingSchedule memory schedule_,
        uint256 amountTotal_
    ) {
        _admin = admin_;

        _token = token_;
        _beneficiary = beneficiary_;
        _state = VestingState(schedule_, amountTotal_, 0, false);
    }

    /**
     * @dev Revokes the vesting schedule, if it is revocable.
     *      Any tokens that are vested but not yet released are sent to the beneficiary,
     *      and the remaining tokens are transferred to the specified address.
     *
     * @param revokeTo The address to send the remaining tokens to
     */
    function revoke(address revokeTo) external validateRevoke(_state, _admin) {
        if (!_state.schedule.revocable) revert Errors.VestingScheduleNotRevocable();
        uint256 vestedAmount = computeReleasableAmount();
        if (vestedAmount > 0) release(vestedAmount);
        uint256 unreleased = _state.amountTotal - _state.released;
        _token.transfer(revokeTo, unreleased);
        _state.revoked = true;
    }

    /**
     * @dev Releases a specified amount of tokens to the beneficiary.
     *      The amount of tokens to be released must be less than or equal to the releasable amount.
     *
     * @param amount The amount of tokens to release
     */
    function release(uint256 amount) public validateRelease(amount, computeReleasableAmount(), _state) {
        _state.released += amount;

        _token.transfer(_beneficiary, amount);
    }

    /**
     * @dev Transfers the vesting schedule to a new beneficiary.
     *
     * @param newBeneficiary_ The address of the new beneficiary
     */
    function transferVesting(address newBeneficiary_) external onlyBeneficiary(_beneficiary) {
        _beneficiary = newBeneficiary_;
    }

    /**
     * @dev Returns the token being vested.
     *
     * @return The token
     */
    function getToken() external view returns (IERC20) {
        return _token;
    }

    /**
     * @dev Returns the vesting state.
     *
     * @return The vesting state
     */
    function getState() external view returns (VestingState memory) {
        return _state;
    }

    /**
     * @dev Returns the amount of tokens that can be withdrawn by the owner if they revoke vesting
     *
     * @return The withdrawable amount
     */

    function getWithdrawableAmount() public view returns (uint256) {
        return _token.balanceOf(address(this)) - computeReleasableAmount();
    }

    /**
     * @dev Computes the amount of tokens that can be released to the beneficiary.
     *      The releasable amount is dependent on the vesting schedule and the current time.
     *
     * @return The releasable amount
     */
    function computeReleasableAmount() public view returns (uint256) {
        // Retrieve the current time.
        uint256 currentTime = block.timestamp;
        // If the current time is before the cliff, no tokens are releasable.
        if ((currentTime < _state.schedule.cliff) || _state.revoked) {
            return 0;
        }
        // If the current time is after the vesting period, all tokens are releasable,
        // minus the amount already released.
        else if (currentTime >= _state.schedule.start + _state.schedule.duration) {
            return _state.amountTotal - _state.released;
        }
        // Otherwise, some tokens are releasable.
        else {
            // Compute the number of full vesting periods that have elapsed.
            uint256 timeFromStart = currentTime - _state.schedule.start;
            uint256 secondsPerSlice = _state.schedule.slicePeriodSeconds;
            uint256 vestedSlicePeriods = timeFromStart / secondsPerSlice;
            uint256 vestedSeconds = vestedSlicePeriods * secondsPerSlice;
            // Compute the amount of tokens that are vested.
            uint256 vestedAmount = (_state.amountTotal * vestedSeconds) / _state.schedule.duration;
            // Subtract the amount already released and return.
            return vestedAmount - _state.released;
        }
    }
}
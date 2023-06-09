// SPDX-License-Identifier: MIT
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  */

// https://github.com/DAObox/liquid-protocol/blob/main/src/modifiers/SimpleHatch.sol
pragma solidity >=0.8.17;

import { Errors } from "../lib/Errors.sol";
import { HatchStatus, HatchState } from "../lib/Types.sol";

abstract contract Modifiers {
    modifier validateContribution(HatchState memory state, uint256 amount) {
        if (state.status != HatchStatus.OPEN) revert Errors.HatchNotOpen();
        if (state.raised + amount > state.params.maximumRaise) revert Errors.MaxContributionReached();
        if (block.timestamp > state.params.hatchDeadline) revert Errors.ContributionWindowClosed();
        _;
    }

    modifier validateRefund(HatchState memory state, uint256 amount) {
        if (state.status != HatchStatus.CANCELED) revert Errors.HatchNotCanceled();
        if (amount == 0) revert Errors.NoContribution();
        _;
    }
    
    modifier validateClaimVesting(HatchState memory state, uint256 amount) {
        if (state.status != HatchStatus.HATCHED) revert Errors.HatchingNotStarted();
        if (amount == 0) revert Errors.NoContribution();
        _;
    }
    
    modifier validateHatch(HatchState memory state) {
        if (state.status != HatchStatus.OPEN) revert Errors.HatchNotOpen();
        if (block.timestamp < state.params.hatchDeadline) {
            // Check if early hatching is possible
            if (state.raised < state.params.maximumRaise) revert Errors.NotEnoughRaised();
        }
        else {
            // Check if normal hatching is possbile
            if (state.raised < state.params.minimumRaise) revert Errors.NotEnoughRaised();
        }
        _;
    }
    
    modifier validateCancel(HatchState memory state) {
        if (state.status != HatchStatus.OPEN) revert Errors.HatchNotOpen();
        if (block.timestamp < state.params.hatchDeadline) revert Errors.HatchOngoing();
        if (state.raised >= state.params.minimumRaise) revert Errors.MinRaiseMet();
        _;
    }
}
// SPDX-License-Identifier: MIT
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  */

// https://github.com/DAObox/liquid-protocol/blob/main/src/modifiers/MarketMaker.sol
pragma solidity >=0.8.17;

import { Errors } from "../lib/Errors.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

abstract contract Modifiers {
    modifier nonZeroAddress(address _address) {
        if (_address == address(0)) revert Errors.AddressCannotBeZero();
        _;
    }

    modifier isPPM(uint32 _amount) {
        if (_amount == 1_000_000) revert Errors.InvalidPPMValue(_amount);
        _;
    }

    modifier validateReserve(IERC20 token) {
        if (token.balanceOf(address(this)) == 0) revert Errors.InitialReserveCannotBeZero();
        _;
    }

    modifier isTradingOpen(bool _isTradingOpen) {
        if (_isTradingOpen) revert Errors.TradingAlreadyOpened();
        _;
    }

    modifier isDepositZero(uint256 _amount) {
        if (_amount == 0) revert Errors.DepositAmountCannotBeZero();
        _;
    }

    modifier postHatch(bool _hatched) {
        if (_hatched == false) revert Errors.HatchingNotStarted();
        _;
    }

    modifier preHatch(bool _hatched) {
        if (_hatched == true) revert Errors.HatchingAlreadyStarted();
        _;
    }
}
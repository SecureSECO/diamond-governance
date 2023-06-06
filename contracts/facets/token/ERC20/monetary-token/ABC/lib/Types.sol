// SPDX-License-Identifier: MIT
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  */

// https://github.com/DAObox/liquid-protocol/blob/main/src/lib/Types.sol
pragma solidity >=0.8.17;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IBondedToken } from "../interfaces/IBondedToken.sol";
import { IBondingCurve } from "../interfaces/IBondingCurve.sol";
import { IMarketMaker } from "../interfaces/IMarketMaker.sol";

/// @notice This struct holds the key parameters that define a bonding curve for a token.
/// @dev These parameters can be updated over time to change the behavior of the bonding curve.
struct CurveParameters {
    /// @notice  fraction of buy funds that go to the DAO.
    /// @dev This value is represented in  fraction (in PPM)
    /// The funds collected here could be used for various purposes like development, marketing, etc., depending on the
    /// DAO's decisions.
    uint32 theta;
    /// @notice  fraction of sell funds that are redistributed to the Pool.
    /// @dev This value is represented in fraction (in PPM)
    /// This "friction" is used to discourage burning and maintain stability in the token's price.
    uint32 friction;
    /// @notice The reserve ratio of the bonding curve, represented in parts per million (ppm), ranging from 1 to
    /// 1,000,000.
    /// @dev The reserve ratio corresponds to different formulas in the bonding curve:
    ///      - 1/3 corresponds to y = multiple * x^2 (exponential curve)
    ///      - 1/2 corresponds to y = multiple * x (linear curve)
    ///      - 2/3 corresponds to y = multiple * x^(1/2) (square root curve)
    /// The reserve ratio determines the price sensitivity of the token to changes in supply.
    uint32 reserveRatio;
    /// @notice The implementation of the curve.
    /// @dev This is the interface of the bonding curve contract.
    /// Different implementations can be used to change the behavior of the curve, such as linear, exponential, etc.
    IBondingCurve formula;
}

struct VestingSchedule {
    // cliff period in seconds
    uint256 cliff;
    // start time of the vesting period
    uint256 start;
    // duration of the vesting period in seconds
    uint256 duration;
    // duration of a slice period for the vesting in seconds
    uint256 slicePeriodSeconds;
    // whether or not the vesting is revocable
    bool revocable;
}

struct VestingState {
    VestingSchedule schedule;
    // total amount of tokens to be released at the end of the vesting
    uint256 amountTotal;
    // amount of tokens released
    uint256 released;
    // whether or not the vesting has been revoked
    bool revoked;
}

enum HatchStatus {
    OPEN,
    HATCHED,
    CANCELED
}

struct HatchParameters {
    // External token contract (Stablecurrency e.g. DAI).
    IERC20 externalToken;
    IBondedToken bondedToken;
    IMarketMaker pool;
    uint256 initialPrice;
    uint256 minimumRaise;
    uint256 maximumRaise;
    // Time (in seconds) by which the curve must be hatched since initialization.
    uint256 hatchDeadline;
}

struct HatchState {
    HatchParameters params;
    HatchStatus status;
    uint256 raised;
}
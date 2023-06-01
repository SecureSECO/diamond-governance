// SPDX-License-Identifier: MIT
/**
 * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
 * © Copyright Utrecht University (Department of Information and Computing Sciences)
 */

pragma solidity ^0.8.0;

import {ABDKMath64x64} from "./ABDKMath64x64.sol";

library LibCalculateGrowth {
    /// @notice Calculate linear growth
    /// @param _initialAmount b
    /// @param _time x
    /// @param _slope a
    /// @return result in 64.64
    function calculateLinearGrowth(
        int128 _initialAmount,
        uint _time,
        int128 _slope
    ) internal pure returns (int128 result) {
        int128 growth = ABDKMath64x64.mul(
            _slope,
            ABDKMath64x64.fromUInt(_time)
        );

        result = ABDKMath64x64.add(_initialAmount, growth);
    }

    /// @notice Calculate exponential growth
    /// @param _initialAmount b
    /// @param _time x
    /// @param _base a
    /// @return result in 64.64
    function calculateExponentialGrowth(
        int128 _initialAmount,
        uint _time,
        int128 _base
    ) internal pure returns (int128 result) {
        int128 growth = ABDKMath64x64.pow(_base, _time);

        result = ABDKMath64x64.mul(_initialAmount, growth);
    }
}

// SPDX-License-Identifier: MIT
/**
 * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
 * © Copyright Utrecht University (Department of Information and Computing Sciences)
 */

pragma solidity ^0.8.0;

import {ABDKMathQuad} from "../../libraries/abdk-math/ABDKMathQuad.sol";

library LibCalculateGrowth {
    /// @notice Calculate linear growth
    /// @param _initialAmount b
    /// @param _time x
    /// @param _slope a
    /// @return result in quad float
    function calculateLinearGrowth(
        bytes16 _initialAmount,
        uint _time,
        bytes16 _slope
    ) internal pure returns (bytes16 result) {
        bytes16 growth = ABDKMathQuad.mul(
            _slope,
            ABDKMathQuad.fromUInt(_time)
        );

        result = ABDKMathQuad.add(_initialAmount, growth);
    }

    /// @notice Calculate exponential growth
    /// @param _initialAmount b
    /// @param _time x
    /// @param _base a
    /// @return result in quad float
    function calculateExponentialGrowth(
        bytes16 _initialAmount,
        uint _time,
        bytes16 _base
    ) internal pure returns (bytes16 result) {
        bytes16 growth = ABDKMathQuad.exp(ABDKMathQuad.mul(ABDKMathQuad.ln(_base), ABDKMathQuad.fromUInt(_time)));

        result = ABDKMathQuad.mul(_initialAmount, growth);
    }
}

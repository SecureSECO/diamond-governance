// SPDX-License-Identifier: MIT
/**
 * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
 * © Copyright Utrecht University (Department of Information and Computing Sciences)
 */

pragma solidity ^0.8.0;

import {ABDKMathQuad} from "./ABDKMathQuad.sol";

/**
 * @title LibABDKHelper
 * @author Utrecht University
 * @notice Library to convert uint(256) to 18 decimals needed for ABDKMatchQuad.sol
 */
library LibABDKHelper {
    // This is a precalculated value of 1e18 in quad float fixed point
    bytes16 constant DECIMALS_18_QUAD = 0x403abc16d674ec800000000000000000;

    function from18DecimalsQuad(
        uint _input
    ) internal pure returns (bytes16 output) {
        output = ABDKMathQuad.div(
            ABDKMathQuad.fromUInt(_input),
            DECIMALS_18_QUAD
        );
    }

    function to18DecimalsQuad(
        bytes16 input
    ) internal pure returns (uint amount) {
        amount = ABDKMathQuad.toUInt(ABDKMathQuad.mul(input, DECIMALS_18_QUAD));
    }
}

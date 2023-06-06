// SPDX-License-Identifier: MIT
/**
 * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
 * © Copyright Utrecht University (Department of Information and Computing Sciences)
 */

pragma solidity ^0.8.0;

import {ABDKMathQuad} from "./ABDKMathQuad.sol";

library LibABDKHelper {
    // This is a precalculated value of 1e18 in quad float fixed point
    bytes16 constant DECIMALS_18_QUAD = 0x403abc16d674ec800000000000000000;

    function from18DecimalsQuad(
        uint _input
    ) internal pure returns (bytes16 output) {
        // Split number up into float part and integer part
        uint ipart;
        uint fpart;

        unchecked {
            ipart = _input / 1e18;
            fpart = _input % 1e18;
        }

        output = ABDKMathQuad.fromUInt(ipart);
        output = ABDKMathQuad.add(
            output,
            ABDKMathQuad.div(ABDKMathQuad.fromUInt(fpart), DECIMALS_18_QUAD)
        );

        assert(
            ABDKMathQuad.eq(
                output,
                ABDKMathQuad.div(
                    ABDKMathQuad.fromUInt(_input),
                    DECIMALS_18_QUAD
                )
            )
        );
        output = ABDKMathQuad.div(
            ABDKMathQuad.fromUInt(_input),
            DECIMALS_18_QUAD
        );
    }

    function to18DecimalsQuad(
        bytes16 input
    ) internal pure returns (uint amount) {
        // Split number up into float part and integer part
        uint ipart;
        uint fpart;

        ipart = ABDKMathQuad.toUInt(input);
        fpart = ABDKMathQuad.toUInt(
            ABDKMathQuad.mul(
                ABDKMathQuad.sub(input, ABDKMathQuad.fromUInt(ipart)),
                DECIMALS_18_QUAD
            )
        );

        amount = ipart * 1e18 + fpart;

        assert(
            amount ==
                ABDKMathQuad.toUInt(ABDKMathQuad.mul(input, DECIMALS_18_QUAD))
        );
        amount = ABDKMathQuad.toUInt(ABDKMathQuad.mul(input, DECIMALS_18_QUAD));
    }
}

// SPDX-License-Identifier: MIT
/**
 * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
 * © Copyright Utrecht University (Department of Information and Computing Sciences)
 */

pragma solidity ^0.8.0;

import {ABDKMath64x64} from "./ABDKMath64x64.sol";

library LibABDKHelper {
    // This is a precalculated value of 1e18 in 64.64 fixed point
    int128 constant DECIMALS_18 = 18446744073709551616000000000000000000;

    /// @notice Convert uint to 64x64 fixed point
    /// @param input uint to convert
    /// @return amount 64x64 fixed point number
    function from18Decimals(uint input) internal pure returns (int128 amount) {
        // Split number up into float part and integer part
        uint ipart;
        uint fpart;

        // Supposedly more gas efficient
        unchecked {
            ipart = input / 1e18;
            fpart = input % 1e18;
        }

        amount = ABDKMath64x64.fromUInt(ipart);
        amount = ABDKMath64x64.add(
            amount,
            ABDKMath64x64.div(ABDKMath64x64.fromUInt(fpart), DECIMALS_18)
        );
    }

    /// @notice Convert 64x64 fixed point to uint (in 18 decimals)
    /// @param input 64x64 fixed point number
    /// @return amount uint (in 18 decimals)
    function to18Decimals(int128 input) internal pure returns (uint amount) {
        // Split number up into float part and integer part
        uint ipart;
        uint fpart;

        ipart = ABDKMath64x64.toUInt(input);
        fpart = ABDKMath64x64.toUInt(
            ABDKMath64x64.mul(
                ABDKMath64x64.sub(input, ABDKMath64x64.fromUInt(ipart)),
                DECIMALS_18
            )
        );

        amount = ipart * 1e18 + fpart;
    }
}

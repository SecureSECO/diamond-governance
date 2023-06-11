// SPDX-License-Identifier: MIT
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  */

// https://github.com/DAObox/liquid-protocol/blob/main/src/math/BancorBondingCurve.sol
pragma solidity >=0.8.17;

import { BancorFormula } from "../math/BancorFormula.sol";
import { IBondingCurve } from "../interfaces/IBondingCurve.sol";

/**
 * @title BancorBondingCurve
 * @author DAOBox | (@pythonpete32)
 * @dev This contract implements the Bancor Formula for a bonding curve. The Bancor Formula provides
 *      a way to calculate the price and the return of tokens for continuous token models.
 *
 *      The contract provides two main functionalities:
 *      1. Calculating the reward for minting continuous tokens.
 *      2. Calculating the refund for burning continuous tokens.
 *
 * @notice Please use this contract responsibly and understand the implications of the bonding curve
 *         and continuous minting/burning on your token's economics.
 */
contract BancorBondingCurve is IBondingCurve, BancorFormula {
    /// @inheritdoc IBondingCurve
    function getContinuousMintReward(
        uint256 depositAmount,
        uint256 continuousSupply,
        uint256 reserveBalance,
        uint32 reserveRatio
    )
        public
        view
        returns (uint256)
    {
        return calculatePurchaseReturn({
            _supply: continuousSupply,
            _reserveBalance: reserveBalance,
            _reserveRatio: reserveRatio,
            _depositAmount: depositAmount
        });
    }

    /// @inheritdoc IBondingCurve
    function getContinuousBurnRefund(
        uint256 _continuousTokenAmount,
        uint256 _continuousSupply,
        uint256 _reserveBalance,
        uint32 _reserveRatio
    )
        public
        view
        returns (uint256)
    {
        return calculateSaleReturn(_continuousSupply, _reserveBalance, _reserveRatio, _continuousTokenAmount);
    }
}
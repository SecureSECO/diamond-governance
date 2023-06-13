// SPDX-License-Identifier: MIT
/**
 * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
 * © Copyright Utrecht University (Department of Information and Computing Sciences)
 */

pragma solidity ^0.8.0;

import {LibABDKHelper} from "../../libraries/abdk-math/LibABDKHelper.sol";

/**
 * @title IRewardMultiplierFacet
 * @author Utrecht University
 * @notice This interface defines the tracking of variables with a certain grow.
 * It also has helper functions to apply the variable to a certain value.
 */
abstract contract IRewardMultiplierFacet {
    enum MultiplierType {
        NONE,
        LINEAR,
        EXPONENTIAL,
        CONSTANT
    }

    /* ========== STRUCTS ========== */
    /* The following structs are used to store the multiplier information for each reward multiplier. */
    struct MultiplierInfo {
        uint startBlock;
        bytes16 initialAmount;
        MultiplierType multiplierType;
    }

    struct LinearParams {
        bytes16 slope;
    }

    struct ExponentialParams {
        bytes16 base;
    }

    /// @notice This function applies a multiplier to a number while keeping the most precision
    /// @dev Returns the multiplier for a given variable name applied to a given amount
    /// @param _name Name of the multiplier variable
    /// @param _amount Number in 18 precision to apply the multiplier to
    /// @return uint Result in 18 precision
    function applyMultiplier(
        string memory _name,
        uint _amount
    ) public view virtual returns (uint);

    /// @dev Returns the multiplier for a given reward multiplier variable (name)
    /// @param _name The name of the multiplier variable
    /// @return uint The multiplier
    function getMultiplier(
        string memory _name
    ) public view virtual returns (uint) {
        return LibABDKHelper.to18DecimalsQuad(getMultiplierQuad(_name));
    }

    /// @notice Return multiplier for a variable
    /// @param _name Name of the variable
    /// @return int128 Multiplier in quad float
    function getMultiplierQuad(
        string memory _name
    ) public view virtual returns (bytes16);

    /* ========== SETTER FUNCTIONS ========== */
    /* The following functions are used to set the multiplier type of a reward multiplier variable.
     * The functions follow the same pattern:
     * @dev Sets the multiplier type to constant
     * @param _name The name of the multiplier
     * @param _startBlock The block number at which the multiplier starts
     * @param _initialAmount The initial amount of the multiplier
     * + any additional parameters for the specific multiplier type
     */
    function setMultiplierTypeConstant(
        string memory _name,
        uint _startBlock,
        uint _initialAmount
    ) external virtual;

    function setMultiplierTypeLinear(
        string memory _name,
        uint _startBlock,
        uint _initialAmount,
        uint _slopeN,
        uint _slopeD
    ) external virtual;

    function setMultiplierTypeExponential(
        string memory _name,
        uint _startBlock,
        uint _initialAmount,
        uint _baseN,
        uint _baseD
    ) external virtual;
}

// SPDX-License-Identifier: MIT
/**
 * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
 * © Copyright Utrecht University (Department of Information and Computing Sciences)
 */

pragma solidity ^0.8.0;

abstract contract IRewardMultiplierFacet {
    enum MultiplierType { NONE, LINEAR, EXPONENTIAL, CONSTANT }

    /* ========== STRUCTS ========== */
    /* The following structs are used to store the multiplier information for each reward multiplier. */
    struct MultiplierInfo {
        uint startBlock;
        uint initialAmount;
        MultiplierType multiplierType; 
    }

    struct LinearParams {
        uint slope;
    }

    struct ExponentialParams {
        uint baseN;
        uint baseD;
    }

    /// @dev Returns the multiplier for a given reward multiplier variable (name)
    /// @param _name The name of the multiplier variable
    /// @return uint The multiplier
    function getMultiplier(string memory _name) internal view virtual returns (uint);

    /* ========== SETTER FUNCTIONS ========== */
    /* The following functions are used to set the multiplier type of a reward multiplier variable.
    * The functions follow the same pattern:
    * @dev Sets the multiplier type to constant
    * @param _name The name of the multiplier
    * @param _startBlock The block number at which the multiplier starts
    * @param _initialAmount The initial amount of the multiplier
    * + any additional parameters for the specific multiplier type
     */
    function setMultiplierTypeConstant(string memory _name, uint _startBlock, uint _initialAmount) external virtual;

    function setMultiplierTypeLinear(string memory _name, uint _startBlock, uint _initialAmount, uint _slope) external virtual;

    function setMultiplierTypeExponential(string memory _name, uint _startBlock, uint _initialAmount, uint _baseN, uint _baseD) external virtual;
}

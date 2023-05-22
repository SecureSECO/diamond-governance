// SPDX-License-Identifier: MIT
/**
 * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
 * © Copyright Utrecht University (Department of Information and Computing Sciences)
 */

pragma solidity ^0.8.0;

import { IRewardMultiplierFacet } from "./IRewardMultiplierFacet.sol";
import { LibRewardMultiplierStorage } from "../../libraries/storage/LibRewardMultiplierStorage.sol";
import { AuthConsumer } from "../../utils/AuthConsumer.sol";
import { IFacet } from "../IFacet.sol";

contract RewardMultiplierFacet is AuthConsumer, IRewardMultiplierFacet, IFacet {
    // Permission used by the setMultiplierType* functions
    bytes32 public constant UPDATE_MULTIPLIER_TYPE_MEMBER_PERMISSION_ID = keccak256("UPDATE_MULTIPLIER_TYPE_MEMBER_PERMISSION");

    /// @inheritdoc IFacet
    function init(bytes memory /*_initParams*/) public virtual override {
        __RewardMultiplierFacet_init();
    }

    function __RewardMultiplierFacet_init() public virtual {
        registerInterface(type(IRewardMultiplierFacet).interfaceId);
    }
    
    /// @inheritdoc IFacet
    function deinit() public virtual override {
        unregisterInterface(type(IRewardMultiplierFacet).interfaceId);
        super.deinit();
    }

    /// @inheritdoc IRewardMultiplierFacet
    function getMultiplier(string memory _name) internal view virtual override returns (uint) {
        LibRewardMultiplierStorage.Storage storage s = LibRewardMultiplierStorage.getStorage();
        MultiplierInfo memory info = s.rewardMultiplier[_name];
        uint numberOfBlocksPassed = block.number - info.startBlock;

        // If the multiplier has not started yet, return 0
        if (info.multiplierType == MultiplierType.CONSTANT) {
            return info.initialAmount;
        } else if (info.multiplierType == MultiplierType.LINEAR) {
            LinearParams memory params = s.linearParams[_name];
            // FIXME: Precision
            return info.initialAmount + numberOfBlocksPassed * params.slope;
        } else if (info.multiplierType == MultiplierType.EXPONENTIAL) {
            ExponentialParams memory params = s.exponentialParams[_name];
            // FIXME: This can easily overflow
            return info.initialAmount + power(); //params.base ** numberOfBlocksPassed;
        }

        return info.initialAmount;
    }

    /// @inheritdoc IRewardMultiplierFacet
    function setMultiplierTypeConstant(string memory _name, uint _startBlock, uint _initialAmount) external override auth(UPDATE_MULTIPLIER_TYPE_MEMBER_PERMISSION_ID) {
        LibRewardMultiplierStorage.Storage storage s = LibRewardMultiplierStorage.getStorage();
        s.rewardMultiplier[_name] = MultiplierInfo(_startBlock, _initialAmount, MultiplierType.CONSTANT);
    }

    /// @inheritdoc IRewardMultiplierFacet
    function setMultiplierTypeLinear(string memory _name, uint _startBlock, uint _initialAmount, uint _slope) external override auth(UPDATE_MULTIPLIER_TYPE_MEMBER_PERMISSION_ID) {
        LibRewardMultiplierStorage.Storage storage s = LibRewardMultiplierStorage.getStorage();
        s.rewardMultiplier[_name] = MultiplierInfo(_startBlock, _initialAmount, MultiplierType.CONSTANT);
        s.linearParams[_name] = LinearParams(_slope);
    }

    /// @inheritdoc IRewardMultiplierFacet
    function setMultiplierTypeExponential(string memory _name, uint _startBlock, uint _initialAmount, uint _baseN, uint _baseD) external override auth(UPDATE_MULTIPLIER_TYPE_MEMBER_PERMISSION_ID) {
        LibRewardMultiplierStorage.Storage storage s = LibRewardMultiplierStorage.getStorage();
        s.rewardMultiplier[_name] = MultiplierInfo(_startBlock, _initialAmount, MultiplierType.CONSTANT);
        s.exponentialParams[_name] = ExponentialParams(_baseN, _baseD);
    }

    function power(uint _baseN, uint _baseD, uint _expN, uint _expD) internal pure returns (uint) {

    }
}

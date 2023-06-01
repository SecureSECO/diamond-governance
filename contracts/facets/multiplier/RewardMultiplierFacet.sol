// SPDX-License-Identifier: MIT
/**
 * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
 * © Copyright Utrecht University (Department of Information and Computing Sciences)
 */

pragma solidity ^0.8.0;

import {IRewardMultiplierFacet} from "./IRewardMultiplierFacet.sol";
import {LibRewardMultiplierStorage} from "../../libraries/storage/LibRewardMultiplierStorage.sol";
import {AuthConsumer} from "../../utils/AuthConsumer.sol";
import {IFacet} from "../IFacet.sol";
import {ABDKMath64x64} from "../../libraries/abdk-math/ABDKMath64x64.sol";
import {LibABDKHelper} from "../../libraries/abdk-math/LibABDKHelper.sol";
import {LibCalculateGrowth} from "./LibCalculateGrowth.sol";

contract RewardMultiplierFacet is AuthConsumer, IRewardMultiplierFacet, IFacet {
    // Permission used by the setMultiplierType* functions
    bytes32 public constant UPDATE_MULTIPLIER_TYPE_MEMBER_PERMISSION_ID =
        keccak256("UPDATE_MULTIPLIER_TYPE_MEMBER_PERMISSION");

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
    function applyMultiplier(
        string memory _name,
        uint _amount
    ) public view virtual override returns (uint) {
        int128 multiplier = _getMultiplier64x64(_name);
        return ABDKMath64x64.mulu(multiplier, _amount);
    }

    /// @inheritdoc IRewardMultiplierFacet
    function getMultiplier(
        string memory _name
    ) public view virtual override returns (uint) {
        int128 multiplier = _getMultiplier64x64(_name);
        return LibABDKHelper.to18Decimals(multiplier);
    }

    /// @inheritdoc IRewardMultiplierFacet
    function setMultiplierTypeConstant(
        string memory _name,
        uint _startBlock,
        uint _initialAmount
    ) external override auth(UPDATE_MULTIPLIER_TYPE_MEMBER_PERMISSION_ID) {
        LibRewardMultiplierStorage.Storage
            storage s = LibRewardMultiplierStorage.getStorage();
        s.rewardMultiplier[_name] = MultiplierInfo(
            _startBlock,
            LibABDKHelper.from18Decimals(_initialAmount),
            MultiplierType.CONSTANT
        );
    }

    /// @inheritdoc IRewardMultiplierFacet
    function setMultiplierTypeLinear(
        string memory _name,
        uint _startBlock,
        uint _initialAmount,
        uint _slopeN,
        uint _slopeD
    ) external override auth(UPDATE_MULTIPLIER_TYPE_MEMBER_PERMISSION_ID) {
        LibRewardMultiplierStorage.Storage
            storage s = LibRewardMultiplierStorage.getStorage();
        s.rewardMultiplier[_name] = MultiplierInfo(
            _startBlock,
            LibABDKHelper.from18Decimals(_initialAmount),
            MultiplierType.LINEAR
        );
        int128 _slope = ABDKMath64x64.divu(_slopeN, _slopeD);

        s.linearParams[_name] = LinearParams(_slope);
    }

    /// @inheritdoc IRewardMultiplierFacet
    function setMultiplierTypeExponential(
        string memory _name,
        uint _startBlock,
        uint _initialAmount,
        uint _baseN,
        uint _baseD
    ) external override auth(UPDATE_MULTIPLIER_TYPE_MEMBER_PERMISSION_ID) {
        LibRewardMultiplierStorage.Storage
            storage s = LibRewardMultiplierStorage.getStorage();
        s.rewardMultiplier[_name] = MultiplierInfo(
            _startBlock,
            LibABDKHelper.from18Decimals(_initialAmount),
            MultiplierType.EXPONENTIAL
        );

        int128 _base = ABDKMath64x64.div(
            ABDKMath64x64.fromUInt(_baseN),
            ABDKMath64x64.fromUInt(_baseD)
        );
        s.exponentialParams[_name] = ExponentialParams(_base);
    }

    /// @notice Return multiplier for a variable
    /// @param _name Name of the variable
    /// @return int128 Multiplier in 64.64
    function _getMultiplier64x64(
        string memory _name
    ) internal view returns (int128) {
        LibRewardMultiplierStorage.Storage
            storage s = LibRewardMultiplierStorage.getStorage();

        MultiplierInfo memory _info = s.rewardMultiplier[_name];

        uint _numBlocksPassed = block.number - _info.startBlock;

        // If the multiplier has not started yet, return 0
        if (_info.multiplierType == MultiplierType.CONSTANT) {
            return _info.initialAmount;
        } else if (_info.multiplierType == MultiplierType.LINEAR) {
            LinearParams memory params = s.linearParams[_name];
            return
                LibCalculateGrowth.calculateLinearGrowth(
                    _info.initialAmount,
                    _numBlocksPassed,
                    params.slope
                );
        } else if (_info.multiplierType == MultiplierType.EXPONENTIAL) {
            ExponentialParams memory params = s.exponentialParams[_name];
            return
                LibCalculateGrowth.calculateExponentialGrowth(
                    _info.initialAmount,
                    _numBlocksPassed,
                    params.base
                );
        }

        return 0;
    }
}

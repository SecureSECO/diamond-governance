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
import {ABDKMathQuad} from "../../libraries/abdk-math/ABDKMathQuad.sol";
import {LibABDKHelper} from "../../libraries/abdk-math/LibABDKHelper.sol";
import {LibCalculateGrowth} from "./LibCalculateGrowth.sol";

/**
 * @title RewardMultiplierFacet
 * @author Utrecht University
 * @notice Implementation of IRewardMultiplierFacet.
 */
contract RewardMultiplierFacet is AuthConsumer, IRewardMultiplierFacet, IFacet {
    // Permission used by the setMultiplierType* functions
    bytes32 public constant UPDATE_MULTIPLIER_TYPE_MEMBER_PERMISSION_ID =
        keccak256("UPDATE_MULTIPLIER_TYPE_MEMBER_PERMISSION");

    struct RewardMultiplierFacetInitParams {
        string name;
        uint startBlock;
        uint initialAmount;
        uint slopeN;
        uint slopeD;
    }

    /// @inheritdoc IFacet
    function init(bytes memory _initParams) public virtual override {
        RewardMultiplierFacetInitParams memory _params = abi.decode(_initParams, (RewardMultiplierFacetInitParams));
        __RewardMultiplierFacet_init(_params);
    }

    function __RewardMultiplierFacet_init(RewardMultiplierFacetInitParams memory _initParams) public virtual {
        _setMultiplierTypeLinear(
            _initParams.name,
            _initParams.startBlock,
            _initParams.initialAmount,
            _initParams.slopeN,
            _initParams.slopeD
        );
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
        bytes16 multiplier = getMultiplierQuad(_name);
        return
            ABDKMathQuad.toUInt(
                ABDKMathQuad.mul(multiplier, ABDKMathQuad.fromUInt(_amount))
            );
    }

    /// @inheritdoc IRewardMultiplierFacet
    function getMultiplierQuad(
        string memory _name
    ) public view override returns (bytes16) {
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

    /// @inheritdoc IRewardMultiplierFacet
    function setMultiplierTypeConstant(
        string memory _name,
        uint _startBlock,
        uint _initialAmount
    ) external override auth(UPDATE_MULTIPLIER_TYPE_MEMBER_PERMISSION_ID) {
        _setMultiplierTypeConstant(_name, _startBlock, _initialAmount);
    }

    /// @inheritdoc IRewardMultiplierFacet
    function setMultiplierTypeLinear(
        string memory _name,
        uint _startBlock,
        uint _initialAmount,
        uint _slopeN,
        uint _slopeD
    ) external override auth(UPDATE_MULTIPLIER_TYPE_MEMBER_PERMISSION_ID) {
        _setMultiplierTypeLinear(
            _name,
            _startBlock,
            _initialAmount,
            _slopeN,
            _slopeD
        );
    }

    /// @inheritdoc IRewardMultiplierFacet
    function setMultiplierTypeExponential(
        string memory _name,
        uint _startBlock,
        uint _initialAmount,
        uint _baseN,
        uint _baseD
    ) external override auth(UPDATE_MULTIPLIER_TYPE_MEMBER_PERMISSION_ID) {
        _setMultiplierTypeExponential(
            _name,
            _startBlock,
            _initialAmount,
            _baseN,
            _baseD
        );
    }

    function _setMultiplierTypeConstant(
        string memory _name,
        uint _startBlock,
        uint _initialAmount
    ) internal {
        LibRewardMultiplierStorage.Storage
            storage s = LibRewardMultiplierStorage.getStorage();
        s.rewardMultiplier[_name] = MultiplierInfo(
            _startBlock,
            LibABDKHelper.from18DecimalsQuad(_initialAmount),
            MultiplierType.CONSTANT
        );
    }

    function _setMultiplierTypeLinear(
        string memory _name,
        uint _startBlock,
        uint _initialAmount,
        uint _slopeN,
        uint _slopeD
    ) internal {
        LibRewardMultiplierStorage.Storage
            storage s = LibRewardMultiplierStorage.getStorage();
        s.rewardMultiplier[_name] = MultiplierInfo(
            _startBlock,
            LibABDKHelper.from18DecimalsQuad(_initialAmount),
            MultiplierType.LINEAR
        );
        bytes16 _slope = ABDKMathQuad.div(
            ABDKMathQuad.fromUInt(_slopeN),
            ABDKMathQuad.fromUInt(_slopeD)
        );

        s.linearParams[_name] = LinearParams(_slope);
    }

    function _setMultiplierTypeExponential(
        string memory _name,
        uint _startBlock,
        uint _initialAmount,
        uint _baseN,
        uint _baseD
    ) internal {
        LibRewardMultiplierStorage.Storage
            storage s = LibRewardMultiplierStorage.getStorage();
        s.rewardMultiplier[_name] = MultiplierInfo(
            _startBlock,
            LibABDKHelper.from18DecimalsQuad(_initialAmount),
            MultiplierType.EXPONENTIAL
        );

        bytes16 _base = ABDKMathQuad.div(
            ABDKMathQuad.fromUInt(_baseN),
            ABDKMathQuad.fromUInt(_baseD)
        );
        s.exponentialParams[_name] = ExponentialParams(_base);
    }
}

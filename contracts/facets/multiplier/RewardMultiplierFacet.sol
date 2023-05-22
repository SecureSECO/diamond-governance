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
import {ABDKMath64x64} from "./ABDKMath64x64.sol";

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

    function multipliedAmount(
        string memory _name,
        uint _amount
    ) public view virtual returns (uint) {
        int128 multiplier = _getMultiplier(_name);
        return ABDKMath64x64.mulu(multiplier, _amount);
    }

    /// @inheritdoc IRewardMultiplierFacet
    // Returns multiplier as 18 decimals
    function getMultiplier(
        string memory _name
    ) public view virtual override returns (uint) {
        int128 multiplier = _getMultiplier(_name);
        return to18Decimals(multiplier);
    }

    // Return multiplier as 64.64 fixed point number
    function _getMultiplier(
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
                calculateLinearGrowth(
                    _info.initialAmount,
                    _numBlocksPassed,
                    params.slope
                );
        } else if (_info.multiplierType == MultiplierType.EXPONENTIAL) {
            ExponentialParams memory params = s.exponentialParams[_name];
            return
                calculateExponentialGrowth(
                    _info.initialAmount,
                    _numBlocksPassed,
                    params.base
                );
        }

        return 0;
    }

    // Slope is a 64.64 fixed point number
    function calculateLinearGrowth(
        int128 _initialAmount, // Verified
        uint _time, // Verified
        int128 _slope // Verified
    ) internal pure returns (int128 result) {
        int128 growth = ABDKMath64x64.mul(
            _slope,
            ABDKMath64x64.fromUInt(_time)
        );

        result = ABDKMath64x64.add(_initialAmount, growth);
    }

    function calculateExponentialGrowth(
        int128 _initialAmount,
        uint _time,
        int128 _base
    ) internal pure returns (int128 result) {
        int128 growth = ABDKMath64x64.pow(_base, _time);

        result = ABDKMath64x64.add(_initialAmount, growth);
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
            from18Decimals(_initialAmount),
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
            from18Decimals(_initialAmount),
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
            from18Decimals(_initialAmount),
            MultiplierType.EXPONENTIAL
        );

        int128 _base = ABDKMath64x64.div(
            ABDKMath64x64.fromUInt(_baseN),
            ABDKMath64x64.fromUInt(_baseD)
        );
        s.exponentialParams[_name] = ExponentialParams(_base);
    }

    int128 constant DECIMALS_18 = 18446744073709551616000000000000000000;

    function from18Decimals(uint input) public pure returns (int128 amount) {
        // Split number up into float part and integer part
        uint ipart;
        uint fpart;

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

    function to18Decimals(int128 input) public pure returns (uint amount) {
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

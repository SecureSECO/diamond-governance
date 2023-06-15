// SPDX-License-Identifier: MIT
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  */

// https://github.com/DAObox/liquid-protocol/blob/main/src/core/SimpleHatch.sol
pragma solidity >=0.8.17;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { PluginStandalone } from "../standalone/PluginStandalone.sol";
import { ABDKMathQuad } from "../../../../../../libraries/abdk-math/ABDKMathQuad.sol";
import { LibABDKHelper } from "../../../../../../libraries/abdk-math/LibABDKHelper.sol";

import { MarketMaker } from "./MarketMaker.sol";
import { Vesting } from "./Vesting.sol";
import { Errors } from "../lib/Errors.sol";
import { HatchParameters, HatchStatus, HatchState, VestingSchedule } from "../lib/Types.sol";
import { Modifiers } from "../modifiers/SimpleHatch.sol";

contract SimpleHatch is PluginStandalone, Modifiers {
    HatchState internal _state;

    VestingSchedule internal _schedule;

    mapping(address => uint256) internal _contributions;
    
    mapping(address => Vesting) internal vestingContracts;

    event Contribute(address indexed contributor, uint256 amount);

    event Refund(address indexed contributor, uint256 amount);

    constructor(
        HatchParameters memory params_,
        VestingSchedule memory schedule_
    ) {
        _state = HatchState(params_, HatchStatus.OPEN, 0);
        _schedule = schedule_;
    }

    function contribute(uint256 _amount) external validateContribution(_state, _amount) {
        _state.params.externalToken.transferFrom(msg.sender, address(this), _amount);

        emit Contribute(msg.sender, _amount);

        _state.raised += _amount;
        _contributions[msg.sender] += _amount;
    }

    function refund() external validateRefund(_state, _contributions[msg.sender]) {
        _state.params.externalToken.transferFrom(msg.sender, address(this), _contributions[msg.sender]);

        emit Refund(msg.sender, _contributions[msg.sender]);

        // _state.raised -= _contributions[msg.sender] (not actually needed)
        _contributions[msg.sender] = 0;
    }

    function claimVesting() external validateClaimVesting(_state, _contributions[msg.sender]) {
        uint256 reward = getReward(_contributions[msg.sender]);

        Vesting vesting = new Vesting(dao(), msg.sender, _state.params.bondedToken, _schedule, reward);

        _state.params.bondedToken.transfer(address(vesting), reward);
        
        _contributions[msg.sender] = 0;

        vestingContracts[msg.sender] = vesting;
    }

    function viewVesting() external view returns (Vesting) {
        return vestingContracts[msg.sender];
    }

    function hatch() external validateHatch(_state) {
        if (block.timestamp < _state.params.hatchDeadline) {
            // Early hatch
            _schedule.start = block.timestamp;
        }
        _state.params.externalToken.transfer(address(_state.params.pool), _state.raised);
        _state.params.pool.hatch(getReward(_state.raised), address(this));
        _state.status = HatchStatus.HATCHED;
    }

    function cancel() external validateCancel(_state) {
        _state.status = HatchStatus.CANCELED;
    }

    function getState() external view returns (HatchState memory) {
        return _state;
    }

    function getReward(uint256 _contribution) internal virtual returns (uint256) {
        return ABDKMathQuad.toUInt(ABDKMathQuad.mul(ABDKMathQuad.fromUInt(_contribution), LibABDKHelper.from18DecimalsQuad(_state.params.initialPrice)));
    }
}
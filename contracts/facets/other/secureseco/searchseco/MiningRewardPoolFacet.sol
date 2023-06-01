// SPDX-License-Identifier: MIT
/**
 * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
 * © Copyright Utrecht University (Department of Information and Computing Sciences)
 */

pragma solidity ^0.8.0;

import {IFacet} from "../../../IFacet.sol";
import {IMiningRewardPoolFacet} from "./IMiningRewardPoolFacet.sol";
import {LibMiningRewardStorage} from "../../../../libraries/storage/LibMiningRewardStorage.sol";

contract MiningRewardPoolFacet is IMiningRewardPoolFacet, IFacet {
    // Permission used by the updateTierMapping function
    bytes32 public constant UPDATE_PIGGY_BANK_PERMISSION_ID =
        keccak256("UPDATE_PIGGY_BANK_PERMISSION");

    /// @inheritdoc IFacet
    function init(bytes memory _initParams) public virtual override {}

    function __MiningRewardFacet_init() public virtual {}

    /// @inheritdoc IFacet
    function deinit() public virtual override {}

    /// @inheritdoc IMiningRewardPoolFacet
    function getMiningRewardPool() external view override returns (uint256) {
        return LibMiningRewardStorage.getStorage().piggyBank;
    }

    /// @inheritdoc IMiningRewardPoolFacet
    function increaseMiningRewardPool(uint _amount) external override {
        LibMiningRewardStorage.getStorage().piggyBank += _amount;
    }

    /// @inheritdoc IMiningRewardPoolFacet
    function decreaseMiningRewardPool(uint _amount) external override {
        LibMiningRewardStorage.getStorage().piggyBank -= _amount;
    }
}

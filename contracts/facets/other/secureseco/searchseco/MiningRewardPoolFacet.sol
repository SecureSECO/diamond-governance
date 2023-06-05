// SPDX-License-Identifier: MIT
/**
 * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
 * © Copyright Utrecht University (Department of Information and Computing Sciences)
 */

pragma solidity ^0.8.0;

import {IDAO} from "@aragon/osx/core/plugin/Plugin.sol";
import {IFacet} from "../../../IFacet.sol";
import {IMiningRewardPoolFacet} from "./IMiningRewardPoolFacet.sol";
import {LibMiningRewardStorage} from "../../../../libraries/storage/LibMiningRewardStorage.sol";
import {IChangeableTokenContract} from "../../../token/ERC20/monetary-token/IChangeableTokenContract.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IDAOReferenceFacet} from "../../../aragon/IDAOReferenceFacet.sol";

contract MiningRewardPoolFacet is IMiningRewardPoolFacet, IFacet {
    // Permission used by the updateTierMapping function
    bytes32 public constant UPDATE_PIGGY_BANK_PERMISSION_ID =
        keccak256("UPDATE_PIGGY_BANK_PERMISSION");

    /// @inheritdoc IFacet
    function init(bytes memory /*_initParams*/) public virtual override {
        registerInterface(type(IMiningRewardPoolFacet).interfaceId);
    }

    function __MiningRewardFacet_init() public virtual {}

    /// @inheritdoc IFacet
    function deinit() public virtual override {
        unregisterInterface(type(IMiningRewardPoolFacet).interfaceId);
    }

    /// @inheritdoc IMiningRewardPoolFacet
    function getMiningRewardPool() external view override returns (uint256) {
        return LibMiningRewardStorage.getStorage().miningRewardPool;
    }

    /// @inheritdoc IMiningRewardPoolFacet
    function increaseMiningRewardPool(uint _amount) external override {
        LibMiningRewardStorage.getStorage().miningRewardPool += _amount;
    }

    /// @inheritdoc IMiningRewardPoolFacet
    function decreaseMiningRewardPool(uint _amount) external override {
        LibMiningRewardStorage.getStorage().miningRewardPool -= _amount;
    }

    /// @inheritdoc IMiningRewardPoolFacet
    function rewardCoinsToMiner(address _miner, uint _amount) external override {
        IERC20(IChangeableTokenContract(address(this)).getTokenContractAddress()).transferFrom(
            address(IDAOReferenceFacet(address(this)).dao()),
            _miner,
            _amount
        );
        LibMiningRewardStorage.getStorage().miningRewardPool -= _amount;
    }
}

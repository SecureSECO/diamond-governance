// SPDX-License-Identifier: MIT
/**
 * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
 * © Copyright Utrecht University (Department of Information and Computing Sciences)
 */

pragma solidity ^0.8.0;

import {IDAO} from "@aragon/osx/core/plugin/Plugin.sol";
import {IFacet} from "../IFacet.sol";
import {IVerificationRewardPoolFacet} from "./IVerificationRewardPoolFacet.sol";
import {LibVerificationRewardPoolStorage} from "../../libraries/storage/LibVerificationRewardPoolStorage.sol";
import {IMonetaryTokenFacet} from "../token/ERC20/monetary-token/IMonetaryTokenFacet.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IDAOReferenceFacet} from "../aragon/IDAOReferenceFacet.sol";
import {AuthConsumer} from "../../utils/AuthConsumer.sol";

contract VerificationRewardPoolFacet is IVerificationRewardPoolFacet, AuthConsumer, IFacet {
    bytes32 public constant UPDATE_VERIFICATION_REWARD_POOL_PERMISSION_ID =
        keccak256("UPDATE_VERIFICATION_REWARD_POOL_PERMISSION");

    /// @inheritdoc IFacet
    function init(bytes memory /*_initParams*/) public virtual override {
        registerInterface(type(IVerificationRewardPoolFacet).interfaceId);
    }

    function __VerificationRewardFacet_init() public virtual {}

    /// @inheritdoc IFacet
    function deinit() public virtual override {
        unregisterInterface(type(IVerificationRewardPoolFacet).interfaceId);
    }

    /// @inheritdoc IVerificationRewardPoolFacet
    function getVerificationRewardPool() external view override returns (uint256) {
        return LibVerificationRewardPoolStorage.getStorage().verificationRewardPool;
    }

    /// @inheritdoc IVerificationRewardPoolFacet
    function increaseVerificationRewardPool(uint _amount) external override {
        LibVerificationRewardPoolStorage.getStorage().verificationRewardPool += _amount;
        IERC20(IMonetaryTokenFacet(address(this)).getTokenContractAddress()).transferFrom(
            msg.sender,
            address(IDAOReferenceFacet(address(this)).dao()),
            _amount
        );
    }

    /// @inheritdoc IVerificationRewardPoolFacet
    function decreaseVerificationRewardPool(uint _amount) external override auth(UPDATE_VERIFICATION_REWARD_POOL_PERMISSION_ID) {
        LibVerificationRewardPoolStorage.getStorage().verificationRewardPool -= _amount;
    }

    /// @inheritdoc IVerificationRewardPoolFacet
    function rewardCoinsToVerifyer(address _miner, uint _amount) external override auth(UPDATE_VERIFICATION_REWARD_POOL_PERMISSION_ID) {
        IERC20(IMonetaryTokenFacet(address(this)).getTokenContractAddress()).transferFrom(
            address(IDAOReferenceFacet(address(this)).dao()),
            _miner,
            _amount
        );
        LibVerificationRewardPoolStorage.getStorage().verificationRewardPool -= _amount;
    }
}

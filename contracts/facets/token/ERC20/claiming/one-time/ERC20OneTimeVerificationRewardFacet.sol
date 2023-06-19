// SPDX-License-Identifier: MIT
/**
 * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
 * © Copyright Utrecht University (Department of Information and Computing Sciences)
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

pragma solidity ^0.8.0;

import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

import {IERC20OneTimeVerificationRewardFacet} from "./IERC20OneTimeVerificationRewardFacet.sol";
import {IERC20ClaimableFacet, IMintableGovernanceStructure} from "../IERC20ClaimableFacet.sol";
import {AuthConsumer} from "../../../../../utils/AuthConsumer.sol";
import {IFacet} from "../../../../IFacet.sol";

import {LibERC20OneTimeVerificationRewardStorage} from "../../../../../libraries/storage/LibERC20OneTimeVerificationRewardStorage.sol";
import {SignVerification} from "../../../../../other/verification/SignVerification.sol";
import {VerificationFacet} from "../../../../membership/VerificationFacet.sol";
import {IVerificationRewardPoolFacet} from "../../../../membership/IVerificationRewardPoolFacet.sol";

/**
 * @title ERC20OneTimeVerificationRewardFacet
 * @author Utrecht University
 * @notice Implementation of IERC20OneTimeVerificationRewardFacet
 */
contract ERC20OneTimeVerificationRewardFacet is
    IERC20OneTimeVerificationRewardFacet,
    AuthConsumer,
    IFacet
{
    /// @notice The permission to update claim reward
    bytes32
        public constant UPDATE_ONE_TIME_VERIFICATION_REWARD_SETTINGS_PERMISSION_ID =
        keccak256("UPDATE_ONE_TIME_VERIFICATION_REWARD_SETTINGS_PERMISSION");

    struct ERC20OneTimeVerificationRewardFacetInitParams {
        string[] providers;
        uint256[] repRewards;
        uint256[] coinRewards;
    }

    /// @inheritdoc IFacet
    function init(bytes memory _initParams) public virtual override {
        ERC20OneTimeVerificationRewardFacetInitParams memory _params = abi
            .decode(
                _initParams,
                (ERC20OneTimeVerificationRewardFacetInitParams)
            );
        __ERC20OneTimeVerificationRewardFacet_init(_params);
    }

    function __ERC20OneTimeVerificationRewardFacet_init(
        ERC20OneTimeVerificationRewardFacetInitParams memory _params
    ) public virtual {
        require(
            _params.providers.length == _params.repRewards.length &&
                _params.repRewards.length == _params.coinRewards.length,
            "Providers and rewards array length doesnt match"
        );

        LibERC20OneTimeVerificationRewardStorage.Storage
            storage s = LibERC20OneTimeVerificationRewardStorage.getStorage();
        for (uint i; i < _params.providers.length; ) {
            s.providerReward[
                _params.providers[i]
            ] = IERC20OneTimeVerificationRewardFacet.OneTimeVerificationReward(
                _params.repRewards[i],
                _params.coinRewards[i]
            );
            unchecked {
                i++;
            }
        }

        registerInterface(
            type(IERC20OneTimeVerificationRewardFacet).interfaceId
        );
    }

    /// @inheritdoc IFacet
    function deinit() public virtual override {
        unregisterInterface(
            type(IERC20OneTimeVerificationRewardFacet).interfaceId
        );
        super.deinit();
    }

    /// @inheritdoc IERC20OneTimeVerificationRewardFacet
    function claimVerificationRewardAll() external virtual {
        // _claim(msg.sender);
        IERC20OneTimeVerificationRewardFacet.OneTimeVerificationReward
            memory reward = _tokensClaimable(msg.sender);
        IMintableGovernanceStructure(address(this)).mintVotingPower(
            msg.sender,
            0,
            reward.repReward
        );
        IVerificationRewardPoolFacet(address(this)).rewardCoinsToVerifyer(
            msg.sender,
            reward.coinReward
        );
        _afterClaim(msg.sender);
    }

    /// @inheritdoc IERC20OneTimeVerificationRewardFacet
    function claimVerificationRewardStamp(
        uint256 _stampIndex
    ) external virtual {
        SignVerification.Stamp[] memory stampsAt = VerificationFacet(
            address(this)
        ).getStampsAt(msg.sender, block.timestamp);
        require(_stampIndex < stampsAt.length, "Stamp index out of bound");

        IERC20OneTimeVerificationRewardFacet.OneTimeVerificationReward
            memory reward = LibERC20OneTimeVerificationRewardStorage
                .getStorage()
                .providerReward[stampsAt[_stampIndex].providerId];

        // Reward rep to the verifier
        IMintableGovernanceStructure(address(this)).mintVotingPower(
            msg.sender,
            0,
            reward.repReward
        );

        // Reward coins to the verifier
        IVerificationRewardPoolFacet(address(this)).rewardCoinsToVerifyer(
            msg.sender,
            reward.coinReward
        );

        _afterClaimStamp(
            msg.sender,
            stampsAt[_stampIndex].providerId,
            stampsAt[_stampIndex].userHash
        );
    }

    /// @inheritdoc IERC20OneTimeVerificationRewardFacet
    function getProviderReward(
        string calldata _provider
    )
        external
        view
        virtual
        override
        returns (
            IERC20OneTimeVerificationRewardFacet.OneTimeVerificationReward
                memory
        )
    {
        return
            LibERC20OneTimeVerificationRewardStorage
                .getStorage()
                .providerReward[_provider];
    }

    /// @inheritdoc IERC20OneTimeVerificationRewardFacet
    function setProviderReward(
        string calldata _provider,
        IERC20OneTimeVerificationRewardFacet.OneTimeVerificationReward
            calldata _reward
    )
        external
        virtual
        override
        auth(UPDATE_ONE_TIME_VERIFICATION_REWARD_SETTINGS_PERMISSION_ID)
    {
        LibERC20OneTimeVerificationRewardStorage.getStorage().providerReward[
                _provider
            ] = _reward;
    }

    /// @inheritdoc IERC20OneTimeVerificationRewardFacet
    function tokensClaimableVerificationRewardAll()
        external
        view
        virtual
        returns (
            IERC20OneTimeVerificationRewardFacet.OneTimeVerificationReward
                memory
        )
    {
        return _tokensClaimable(msg.sender);
    }

    /// @inheritdoc IERC20OneTimeVerificationRewardFacet
    function tokensClaimableVerificationRewardStamp(
        uint256 _stampIndex
    )
        external
        view
        virtual
        returns (
            IERC20OneTimeVerificationRewardFacet.OneTimeVerificationReward
                memory
        )
    {
        SignVerification.Stamp[] memory stampsAt = VerificationFacet(
            address(this)
        ).getStampsAt(msg.sender, block.timestamp);
        require(_stampIndex < stampsAt.length, "Stamp index out of bound");
        return
            _tokensClaimableStamp(
                msg.sender,
                stampsAt[_stampIndex].providerId,
                stampsAt[_stampIndex].userHash
            );
    }

    // Copied from IERC20ClaimableFacet.sol
    /// @notice Returns the amount of tokens claimable by the given address (for all stamps).
    /// @param _claimer The address to check.
    /// @return reward The amount of tokens claimable (both coin and rep).
    function _tokensClaimable(
        address _claimer
    )
        internal
        view
        virtual
        returns (
            IERC20OneTimeVerificationRewardFacet.OneTimeVerificationReward
                memory reward
        )
    {
        // Get data from storage
        SignVerification.Stamp[] memory stampsAt = VerificationFacet(
            address(this)
        ).getStampsAt(_claimer, block.timestamp);

        reward = IERC20OneTimeVerificationRewardFacet.OneTimeVerificationReward(
                0,
                0
            );

        for (uint i; i < stampsAt.length; ) {
            IERC20OneTimeVerificationRewardFacet.OneTimeVerificationReward
                memory rewardClaimable = _tokensClaimableStamp(
                    _claimer,
                    stampsAt[i].providerId,
                    stampsAt[i].userHash
                );
            if (rewardClaimable.repReward != 0) {
                reward.repReward += rewardClaimable.repReward;
            }
            if (rewardClaimable.coinReward != 0) {
                reward.coinReward += rewardClaimable.coinReward;
            }

            unchecked {
                i++;
            }
        }
    }

    /// @notice Returns the amount of tokens claimable by the given address for a specific stamp.
    /// @param _claimer The address to check.
    /// @param _provider The provider of the stamp (gh, poh).
    /// @param _stamp The unique id of the stamp to check.
    /// @return reward The amount of tokens claimable (both coin and rep).
    function _tokensClaimableStamp(
        address _claimer,
        string memory _provider,
        string memory _stamp
    )
        internal
        view
        virtual
        returns (
            IERC20OneTimeVerificationRewardFacet.OneTimeVerificationReward
                memory
        )
    {
        LibERC20OneTimeVerificationRewardStorage.Storage
            storage s = LibERC20OneTimeVerificationRewardStorage.getStorage();

        // Maximum reward for the provider
        IERC20OneTimeVerificationRewardFacet.OneTimeVerificationReward
            memory reward = s.providerReward[_provider];

        // Amount already claimed by the claimer for the provider
        IERC20OneTimeVerificationRewardFacet.OneTimeVerificationReward
            memory alreadyClaimed = s.amountClaimedByAddressForProvider[
                _claimer
            ][_provider];

        // Amount already claimed for a unique stamp
        IERC20OneTimeVerificationRewardFacet.OneTimeVerificationReward
            memory amountClaimedForStamp = s.amountClaimedForStamp[_stamp];
        uint verificationRewardPoolBalance = IVerificationRewardPoolFacet(
            address(this)
        ).getVerificationRewardPool();

        return
            IERC20OneTimeVerificationRewardFacet.OneTimeVerificationReward(
                reward.repReward -
                    Math.max(
                        alreadyClaimed.repReward,
                        amountClaimedForStamp.repReward
                    ),
                Math.min( // cap coin reward to the verification reward pool balance
                    reward.coinReward -
                        Math.max(
                            alreadyClaimed.coinReward,
                            amountClaimedForStamp.coinReward
                        ),
                    verificationRewardPoolBalance
                )
            );
    }

    // Copied from IERC20ClaimableFacet.sol
    /// @notice Set the amount of tokens claimed for all stamps.
    /// @param _claimer The address to check.
    function _afterClaim(address _claimer) internal virtual {
        // Get data from storage
        SignVerification.Stamp[] memory stampsAt = VerificationFacet(
            address(this)
        ).getStampsAt(_claimer, block.timestamp);

        for (uint i; i < stampsAt.length; ) {
            _afterClaimStamp(
                _claimer,
                stampsAt[i].providerId,
                stampsAt[i].userHash
            );

            unchecked {
                i++;
            }
        }
    }

    /// @notice Set the amount of tokens claimed for a specific stamp.
    /// @param _claimer Address of the claimer.
    /// @param _provider Provider of the stamp (gh, poh).
    /// @param _stamp Unique id of the stamp to check.
    function _afterClaimStamp(
        address _claimer,
        string memory _provider,
        string memory _stamp
    ) internal virtual {
        LibERC20OneTimeVerificationRewardStorage.Storage
            storage s = LibERC20OneTimeVerificationRewardStorage.getStorage();
        s.amountClaimedByAddressForProvider[_claimer][_provider] = s
            .providerReward[_provider];
        s.amountClaimedForStamp[_stamp] = s.providerReward[_provider];
    }
}

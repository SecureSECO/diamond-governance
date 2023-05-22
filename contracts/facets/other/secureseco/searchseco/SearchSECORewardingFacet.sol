// SPDX-License-Identifier: MIT
/**
 * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
 * © Copyright Utrecht University (Department of Information and Computing Sciences)
 */

pragma solidity ^0.8.0;

import {IDAO} from "@aragon/osx/core/plugin/Plugin.sol";
import {LibSearchSECORewardingStorage} from "../../../../libraries/storage/LibSearchSECORewardingStorage.sol";
import {AuthConsumer} from "../../../../utils/AuthConsumer.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IFacet} from "../../../IFacet.sol";
import {ISearchSECORewardingFacet} from "./ISearchSECORewardingFacet.sol";
import {GenericSignatureHelper} from "../../../../utils/GenericSignatureHelper.sol";

/// @title A contract reward SearchSECO Spider users for submitting new hashes
/// @author J.S.C.L & T.Y.M.W.
/// @notice This contract is used to reward users for submitting new hashes
contract SearchSECORewardingFacet is AuthConsumer, GenericSignatureHelper, ISearchSECORewardingFacet, IFacet {
    // Permission used by the setHashReward function
    bytes32 public constant UPDATE_HASH_REWARD_PERMISSION_ID =
        keccak256("UPDATE_HASH_REWARD_PERMISSION_ID");

    // Permission used by the updateTierMapping function
    bytes32 public constant UPDATE_REWARDING_SIGNER_PERMISSION_ID =
        keccak256("UPDATE_REWARDING_SIGNER_MAPPING_PERMISSION");

    struct SearchSECORewardingFacetInitParams {
        address signer;
    }

    /// @inheritdoc IFacet
    function init(bytes memory _initParams) public virtual override {
        SearchSECORewardingFacetInitParams memory _params = abi.decode(
            _initParams,
            (SearchSECORewardingFacetInitParams)
        );
        __SearchSECORewardingFacet_init(_params);
    }

    function __SearchSECORewardingFacet_init(
        SearchSECORewardingFacetInitParams memory _params
    ) public virtual {
        // Set signer for signature verification
        LibSearchSECORewardingStorage.Storage storage s = LibSearchSECORewardingStorage.getStorage();
        s.signer = _params.signer;
        s.hashReward = 1;

        registerInterface(type(ISearchSECORewardingFacet).interfaceId);
    }

    /// @inheritdoc IFacet
    function deinit() public virtual override {
        unregisterInterface(type(ISearchSECORewardingFacet).interfaceId);
        super.deinit();
    }

    /// @inheritdoc ISearchSECORewardingFacet
    function reward(
        address _toReward,
        uint _hashCount,
        uint _nonce,
        uint _repFrac,
        bytes calldata _proof
    ) external override {
        // This is necessary to read from storage
        LibSearchSECORewardingStorage.Storage
            storage s = LibSearchSECORewardingStorage.getStorage();

        // Validate the given proof
        require(
            verify(s.signer, keccak256(abi.encodePacked(_toReward, _hashCount, _nonce)), _proof),
            "Proof is not valid"
        );

        // Make sure that the hashCount is equal
        require(
            s.hashCount[_toReward] == _nonce,
            "Hash count does not match with nonce"
        );

        s.hashCount[_toReward] += _hashCount;

        require(
            _repFrac >= 0 && _repFrac <= 1_000_000,
            "REP fraction must be between 0 and 1_000_000"
        );

        // Calculate the reward
        uint repReward = ((_hashCount * s.hashReward) * _repFrac) / 1_000_000;
        uint coinReward = (_hashCount * s.hashReward) - repReward;

        assert(repReward + coinReward == s.hashReward);

        // TODO: Reward the user
        // ...
    }

    /// @inheritdoc ISearchSECORewardingFacet
    function getHashCount(address _user) public view override returns (uint) {
        return LibSearchSECORewardingStorage.getStorage().hashCount[_user];
    }

    /// @inheritdoc ISearchSECORewardingFacet
    function getRewardingSigner() external view override returns (address) {
        return LibSearchSECORewardingStorage.getStorage().signer;
    }

    /// @notice Sets the hash reward (REP)
    /// @param _hashReward The new hash reward
    function setHashReward(
        uint _hashReward
    ) public auth(UPDATE_HASH_REWARD_PERMISSION_ID) {
        LibSearchSECORewardingStorage.getStorage().hashReward = _hashReward;
    }

    /// @inheritdoc ISearchSECORewardingFacet
    function setRewardingSigner(
        address _newSigner
    ) external override auth(UPDATE_REWARDING_SIGNER_PERMISSION_ID) {
        LibSearchSECORewardingStorage.Storage
            storage s = LibSearchSECORewardingStorage.getStorage();

        s.signer = _newSigner;
    }
}

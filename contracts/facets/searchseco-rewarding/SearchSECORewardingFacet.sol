// SPDX-License-Identifier: MIT
/**
 * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
 * © Copyright Utrecht University (Department of Information and Computing Sciences)
 */

pragma solidity ^0.8.0;

import {IDAO} from "@aragon/osx/core/plugin/Plugin.sol";
import {LibSearchSECORewardingStorage} from "../../libraries/storage/LibSearchSECORewardingStorage.sol";
import {AuthConsumer} from "../../utils/AuthConsumer.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {SignatureHelper} from "./SignatureHelper.sol";

// Used for diamond pattern storage
library SearchSECORewardingFacetInit {
    struct InitParams {
        address[] users;
        uint[] hashCounts;
    }

    function init(InitParams memory _params) external {
        LibSearchSECORewardingStorage.Storage
            storage s = LibSearchSECORewardingStorage.getStorage();

        require(
            _params.users.length == _params.hashCounts.length,
            "Users and hashCounts must be of equal length"
        );

        for (uint i; i < _params.users.length; ) {
            s.hashCount[_params.users[i]] = _params.hashCounts[i];

            unchecked {
                i++;
            }
        }
    }
}

/// @title A contract reward SearchSECO Spider users for submitting new hashes
/// @author J.S.C.L & T.Y.M.W.
/// @notice This contract is used to reward users for submitting new hashes
contract SearchSECORewardingFacet is AuthConsumer, Ownable, SignatureHelper {
    /// @notice Rewards the user for submitting new hashes
    /// @param _toReward The address of the user to reward
    /// @param _hashCount The number of new hashes the user has submitted
    /// @param _nonce A nonce
    /// @param _proof The proof that the user received from the server
    function reward(
        address _toReward,
        uint _hashCount,
        uint _nonce,
        bytes calldata _proof
    ) public {
        // Validate the given proof
        require(
            verify(owner(), _toReward, _hashCount, _nonce, _proof),
            "Proof is not valid"
        );

        // This is necessary to read from storage
        LibSearchSECORewardingStorage.Storage
            storage s = LibSearchSECORewardingStorage.getStorage();

        // Make sure that the hashCount is equal
        require(
            s.hashCount[_toReward] == _nonce,
            "Hash count does not match with nonce"
        );

        s.hashCount[_toReward] += _hashCount;

        // TODO: Reward the user
        // ...
    }
}

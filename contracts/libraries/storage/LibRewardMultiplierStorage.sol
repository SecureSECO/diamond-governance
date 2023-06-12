// SPDX-License-Identifier: MIT
/**
 * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
 * © Copyright Utrecht University (Department of Information and Computing Sciences)
 */

pragma solidity ^0.8.0;

import { IRewardMultiplierFacet } from "../../facets/multiplier/IRewardMultiplierFacet.sol";

library LibRewardMultiplierStorage {
    bytes32 constant REWARD_MULTIPLIER_STORAGE_POSITION =
        keccak256("reward.multiplier.diamond.storage.position");

    struct Storage {
        // Should be called by inheritors too, thats why public
        mapping (string => IRewardMultiplierFacet.MultiplierInfo) rewardMultiplier;

        mapping (string => IRewardMultiplierFacet.LinearParams) linearParams;
        mapping (string => IRewardMultiplierFacet.ExponentialParams) exponentialParams;
      }

    function getStorage() internal pure returns (Storage storage ds) {
        bytes32 position = REWARD_MULTIPLIER_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
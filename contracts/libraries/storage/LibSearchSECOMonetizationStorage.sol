// SPDX-License-Identifier: MIT
/**
 * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
 * © Copyright Utrecht University (Department of Information and Computing Sciences)
 */

pragma solidity ^0.8.0;

library LibSearchSECOMonetizationStorage {
    bytes32 constant SEARCHSECO_MONETIZATION_STORAGE_POSITION =
        keccak256("searchseco.monetization.diamond.storage.position");

    struct Storage {
        /// @notice how much a single hash costs
        uint256 hashCost;

        /// @notice Defines the ratio between what goes to the treasury and what goes to rewarding the miners.
        uint32 queryMiningRewardPoolRatio; // ppm
    }

    function getStorage() internal pure returns (Storage storage ds) {
        bytes32 position = SEARCHSECO_MONETIZATION_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}

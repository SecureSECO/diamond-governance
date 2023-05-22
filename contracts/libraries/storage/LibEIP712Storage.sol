// SPDX-License-Identifier: MIT
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  */

pragma solidity ^0.8.0;

library LibEIP712Storage {
    bytes32 constant EIP712_STORAGE_POSITION =
        keccak256("eip712.diamond.storage.position");

    struct Storage {
        /* solhint-disable var-name-mixedcase */
        // Cache the domain separator as an immutable value, but also store the chain id that it corresponds to, in order to
        // invalidate the cached domain separator if the chain id changes.
        bytes32 _CACHED_DOMAIN_SEPARATOR;
        uint256 _CACHED_CHAIN_ID;
        address _CACHED_THIS;

        bytes32 _HASHED_NAME;
        bytes32 _HASHED_VERSION;
        bytes32 _TYPE_HASH;

        /* solhint-enable var-name-mixedcase */
    }

    function getStorage() internal pure returns (Storage storage ds) {
        bytes32 position = EIP712_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
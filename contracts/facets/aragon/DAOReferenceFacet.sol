// SPDX-License-Identifier: MIT
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  */

pragma solidity ^0.8.0;

import { IDAO } from "@aragon/osx/core/dao/IDAO.sol";

import { LibDAOReferenceStorage } from "../../libraries/storage/LibDAOReferenceStorage.sol";

library DAOReferenceFacetInit {
    struct InitParams {
        IDAO dao;
    }

    function init(InitParams calldata _params) external {
        LibDAOReferenceStorage.getStorage().dao = _params.dao;
    }
}

contract DAOReferenceFacet {
    /// @notice Returns the DAO contract.
    /// @return The DAO contract.
    function dao() external view returns (IDAO) {
        return LibDAOReferenceStorage.getStorage().dao;
    }
}
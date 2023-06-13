// SPDX-License-Identifier: MIT
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  */

pragma solidity ^0.8.0;

import { IDAO } from "@aragon/osx/core/dao/IDAO.sol";
import { IDAOReferenceFacet } from "./IDAOReferenceFacet.sol";
import { IFacet } from "../IFacet.sol";

import { LibDAOReferenceStorage } from "../../libraries/storage/LibDAOReferenceStorage.sol";

/**
 * @title DAOReferenceFacet
 * @author Utrecht University
 * @notice Implementation of IDAOReferenceFacet.
 */
contract DAOReferenceFacet is IDAOReferenceFacet, IFacet {
    /// @inheritdoc IDAOReferenceFacet
    function dao() external view returns (IDAO) {
        return LibDAOReferenceStorage.getStorage().dao;
    }

    /// @inheritdoc IFacet
    function init(bytes memory/* _initParams*/) public virtual override {
        __DAOReferenceFacet_init();
    }

    function __DAOReferenceFacet_init() public virtual {
        registerInterface(type(IDAOReferenceFacet).interfaceId);
    }

    /// @inheritdoc IFacet
    function deinit() public virtual override {
        unregisterInterface(type(IDAOReferenceFacet).interfaceId);
        super.deinit();
    }
}

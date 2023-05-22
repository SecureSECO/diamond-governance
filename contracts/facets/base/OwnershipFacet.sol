// SPDX-License-Identifier: MIT
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  */

pragma solidity ^0.8.0;

import { LibDiamond } from "../../libraries/LibDiamond.sol";
import { IERC173 } from "../../additional-contracts/IERC173.sol";
import { IFacet } from "../IFacet.sol";

contract OwnershipFacet is IERC173, IFacet {
    /// @inheritdoc IFacet
    function init(bytes memory/* _initParams*/) public virtual override {
        __OwnershipFacet_init();
    }

    function __OwnershipFacet_init() public virtual {
        registerInterface(type(IERC173).interfaceId);
    }

    /// @inheritdoc IFacet
    function deinit() public virtual override {
        unregisterInterface(type(IERC173).interfaceId);
        super.deinit();
    }

    function transferOwnership(address _newOwner) external override {
        LibDiamond.enforceIsContractOwner();
        LibDiamond.setContractOwner(_newOwner);
    }

    function owner() external override view returns (address owner_) {
        owner_ = LibDiamond.contractOwner();
    }
}
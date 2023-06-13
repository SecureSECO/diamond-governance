// SPDX-License-Identifier: MIT
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  */

pragma solidity ^0.8.0;

import { LibDiamond } from "../../libraries/LibDiamond.sol";
import { IERC173 } from "../../additional-contracts/IERC173.sol";
import { IFacet } from "../IFacet.sol";

/**
 * @title OwnershipFacet
 * @author Utrecht University
 * @notice This facet allows the Diamond to be owned by an address, it is based on https://github.com/mudgen/diamond-2-hardhat/blob/main/contracts/facets/OwnershipFacet.sol
 * This facet is not recommended to be used, as its functionality is more limited than our own auth framework.
 * It does not provide any functionality itself, but can be used by other facets for authing functions.
 */
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
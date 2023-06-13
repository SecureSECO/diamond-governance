// SPDX-License-Identifier: MIT
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  */

pragma solidity ^0.8.0;

import { IDiamondCut } from "../../additional-contracts/IDiamondCut.sol";
import { AuthConsumer } from "../../utils/AuthConsumer.sol";
import { LibDiamond } from "../../libraries/LibDiamond.sol";
import { IFacet } from "../IFacet.sol";

/**
 * @title DiamondCutFacet
 * @author Utrecht University
 * @notice This facet allows the Diamond to be cut after deploymend, it is based on https://github.com/mudgen/diamond-2-hardhat/blob/main/contracts/facets/DiamondCutFacet.sol 
 */
contract DiamondCutFacet is IDiamondCut, AuthConsumer, IFacet {
    // Permission to cut the diamond
    bytes32 public constant DIAMOND_CUT_PERMISSION_ID = keccak256("DIAMOND_CUT_PERMISSION");

    /// @inheritdoc IFacet
    function init(bytes memory/* _initParams*/) public virtual override {
        __DiamondCutFacet_init();
    }

    function __DiamondCutFacet_init() public virtual {
        registerInterface(type(IDiamondCut).interfaceId);
    }

    /// @inheritdoc IFacet
    function deinit() public virtual override {
        unregisterInterface(type(IDiamondCut).interfaceId);
        super.deinit();
    }

    /// @notice Add/replace/remove any number of functions and optionally execute
    ///         a function with delegatecall
    /// @param _diamondCut Contains the facet addresses and function selectors
    function diamondCut(FacetCut[] calldata _diamondCut) external virtual override auth(DIAMOND_CUT_PERMISSION_ID) {
        LibDiamond.diamondCut(_diamondCut);
    }
}
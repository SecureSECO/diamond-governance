// SPDX-License-Identifier: MIT
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  */

pragma solidity ^0.8.0;

/******************************************************************************\
* Author: Nick Mudge <nick@perfectabstractions.com> (https://twitter.com/mudgen)
* EIP-2535 Diamonds: https://eips.ethereum.org/EIPS/eip-2535
/******************************************************************************/

import { IDiamondCut } from "../../additional-contracts/IDiamondCut.sol";
import { AuthConsumer } from "../../utils/AuthConsumer.sol";
import { LibDiamond } from "../../libraries/LibDiamond.sol";
import { IFacet } from "../IFacet.sol";

// Remember to add the loupe functions from DiamondLoupeFacet to the diamond.
// The loupe functions are required by the EIP2535 Diamonds standard

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
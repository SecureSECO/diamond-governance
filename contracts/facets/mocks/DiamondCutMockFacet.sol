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
import { LibDiamond } from "../../libraries/LibDiamond.sol";
import { DiamondCutFacet } from "../base/DiamondCutFacet.sol";

// Remember to add the loupe functions from DiamondLoupeFacet to the diamond.
// The loupe functions are required by the EIP2535 Diamonds standard

contract DiamondCutMockFacet {
    /// @notice Add/replace/remove any number of functions and optionally execute
    ///         a function with delegatecall
    /// @param _diamondCut Contains the facet addresses and function selectors
    /// @param _init The address of the contract or facet to execute _calldata
    /// @param _calldata A function call, including function selector and arguments
    ///                  _calldata is executed with delegatecall on _init
    function diamondCutMock(
        IDiamondCut.FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external {
        DiamondCutFacet dcf = DiamondCutFacet(address(this));
        dcf.diamondCut(_diamondCut, _init, _calldata);
    }
}
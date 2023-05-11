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

import {IMintable} from "../token/ERC20/ERC20SearchSECOToken/IMintable.sol";
import {IChangeableTokenContract} from "../token/ERC20/ERC20SearchSECOToken/IChangeableTokenContract.sol";

// Remember to add the loupe functions from DiamondLoupeFacet to the diamond.
// The loupe functions are required by the EIP2535 Diamonds standard

contract MonetaryTokenMockFacet {
    function _mintMonetaryToken(address _account, uint _amount) external {
        IMintable(address(this)).mint(_account, _amount);
    }

    function _setTokenContractAddress(address contractAddress) external {
        IChangeableTokenContract(address(this)).setTokenContractAddress(contractAddress);
    }
}

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

import {IMonetaryTokenMintable} from "../token/ERC20/monetary-token/IMonetaryTokenMintable.sol";
import {IChangeableTokenContract} from "../token/ERC20/monetary-token/IChangeableTokenContract.sol";

contract MonetaryTokenMockFacet {
    function _mintMonetaryToken(address _account, uint _amount) external {
        IMonetaryTokenMintable(address(this)).mintMonetaryToken(_account, _amount);
    }

    function _setTokenContractAddress(address contractAddress) external {
        IChangeableTokenContract(address(this)).setTokenContractAddress(contractAddress);
    }
}

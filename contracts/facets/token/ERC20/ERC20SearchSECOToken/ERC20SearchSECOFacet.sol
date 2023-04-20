// SPDX-License-Identifier: MIT
/**
 * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
 * © Copyright Utrecht University (Department of Information and Computing Sciences)
 */

pragma solidity ^0.8.0;

import {ERC20VotesFacet, ERC20PermitFacet, ERC20Facet} from "../core/ERC20VotesFacet.sol";
import {IMintableGovernanceStructure, IGovernanceStructure} from "../../../governance/structure/voting-power/IMintableGovernanceStructure.sol";
import {AuthConsumer} from "../../../../utils/AuthConsumer.sol";
import {ERC20SearchSECOToken} from "./ERC20SearchSECOToken.sol";
import {LibERC20SearchSECOStorage} from "../../../../libraries/storage/LibERC20SearchSECOStorage.sol";

// Used for diamond pattern storage
library ERC20SearchSECOFacetInit {
    struct InitParams {
        address erc20ContractAddress;
    }

    function init(InitParams calldata _params) external {
        LibERC20SearchSECOStorage.Storage storage s = LibERC20SearchSECOStorage.getStorage();

        s.erc20ContractAddress = _params.erc20ContractAddress;
    }
}

contract ERC20SearchSECOFacet {
    /// @notice Function to trigger the initial coin offering
    /// @param _moneyReceivers The addresses to receive the coin offerings
    /// @param _money The number of coins to send to the respective addresses (in order of _moneyReceivers)
    function ico(
        address[] memory _moneyReceivers,
        uint[] memory _money
    ) external {
        // Get ERC20 contract
        address erc20ContractAddress = LibERC20SearchSECOStorage.getStorage().erc20ContractAddress;
        ERC20SearchSECOToken erc20Contract = ERC20SearchSECOToken(erc20ContractAddress);
        require(
            _moneyReceivers.length == _money.length,
            "Money receivers and money array lengths do not match"
        );
        for (uint i; i < _moneyReceivers.length; ) {
            erc20Contract.mint(_moneyReceivers[i], _money[i]);
            unchecked {
                i++;
            }
        }
    }

    /// @notice This returns the contract address of the ERC20 token contract used
    /// @return address The contract address of the ERC20 token contract
    function getERC20ContractAddress () external view returns (address) {
      return LibERC20SearchSECOStorage.getStorage().erc20ContractAddress;
    }
}

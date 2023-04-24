// SPDX-License-Identifier: MIT
/**
 * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
 * © Copyright Utrecht University (Department of Information and Computing Sciences)
 */

pragma solidity ^0.8.0;

import {IDAO} from "@aragon/osx/core/plugin/Plugin.sol";
import {LibSearchSECOMonetizationStorage} from "../../libraries/storage/LibSearchSECOMonetizationStorage.sol";
import {AuthConsumer} from "../../utils/AuthConsumer.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20SearchSECOFacet} from "../token/ERC20/ERC20SearchSECOToken/ERC20SearchSECOFacet.sol";

// Used for diamond pattern storage
library SearchSECOMonetizationFacetInit {
    struct InitParams {
        uint256 hashCost;
    }

    function init(InitParams calldata _params) external {
        LibSearchSECOMonetizationStorage.getStorage().hashCost = _params
            .hashCost;
    }
}

/// @title SearchSECO monetization facet for the Diamond Governance Plugin
/// @author J.S.C.L. & T.Y.M.W. @ UU
/// @notice This integrates the SearchSECO project into the DAO by monetizing queries and rewarding spiders
contract SearchSECOMonetizationFacet is AuthConsumer {
    event PaymentProcessed(address sender, uint amount, string uniqueId);

    // Permission used by the updateTierMapping function
    bytes32 public constant UPDATE_HASH_COST_MAPPING_PERMISSION_ID =
        keccak256("UPDATE_HASH_COST_MAPPING_PERMISSION");

    /// @notice This function is used to pay for hashes. The user builds a credit of hashes.
    /// @param _amount Number of hashes the user wants to pay for
    function payForHashes(uint _amount, string memory _uniqueId) external {
        LibSearchSECOMonetizationStorage.Storage
            storage s = LibSearchSECOMonetizationStorage.getStorage();
        ERC20SearchSECOFacet erc20SearchSECOFacet = ERC20SearchSECOFacet(address(this));
        IERC20 tokenContract = IERC20(erc20SearchSECOFacet.getERC20ContractAddress());


        // Require that the balance of the sender has sufficient funds for this transaction
        // hashCost is the cost of a single hash
        require(tokenContract.balanceOf(msg.sender) > s.hashCost * _amount, "Insufficient tokens for this transaction");

        tokenContract.transferFrom(msg.sender, address(this), s.hashCost * _amount);
        
        // Emit event so back-end can verify payment
        emit PaymentProcessed(msg.sender, _amount, _uniqueId);
    }

    /// @notice Updates the cost of a hash (in the context of SearchSECO)
    /// @param _newCost The new cost of a hash
    function updateHashCost(uint _newCost) external auth(UPDATE_HASH_COST_MAPPING_PERMISSION_ID) {
        LibSearchSECOMonetizationStorage.getStorage().hashCost = _newCost;
    }

    /// @notice Retrieve the current cost of a hash
    /// @return uint The current hashcost
    function getHashCost() external view returns (uint) {
        return LibSearchSECOMonetizationStorage.getStorage().hashCost;
    }
}

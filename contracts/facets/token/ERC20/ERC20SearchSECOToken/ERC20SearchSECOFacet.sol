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
import {IMonetaryTokenMintable} from "./IMonetaryTokenMintable.sol";

// Used for diamond pattern storage
library ERC20SearchSECOFacetInit {
    struct InitParams {
        address erc20ContractAddress;
    }

    function init(InitParams calldata _params) external {
        LibERC20SearchSECOStorage.Storage storage s = LibERC20SearchSECOStorage
            .getStorage();

        s.erc20ContractAddress = _params.erc20ContractAddress;
    }
}

contract ERC20SearchSECOFacet is IMonetaryTokenMintable, AuthConsumer {
    // Permission used by the setERC20ContractAddress function
    bytes32 public constant SET_MONETARY_TOKEN_CONTRACT_PERMISSION_ID =
        keccak256("SET_MONETARY_TOKEN_CONTRACT_PERMISSION");

    /// @notice Function to mint SECOIN tokens
    /// @param _account The address to receive the minted tokens
    /// @param _amount The amount of tokens to mint
    function mintMonetaryToken(address _account, uint _amount) external {
        // Get ERC20 contract
        address erc20ContractAddress = LibERC20SearchSECOStorage
            .getStorage()
            .erc20ContractAddress;
        ERC20SearchSECOToken erc20Contract = ERC20SearchSECOToken(
            erc20ContractAddress
        );
        erc20Contract.mint(_account, _amount);
    }

    /// @notice This returns the contract address of the ERC20 token contract used
    /// @return address The contract address of the ERC20 token contract
    function getMonetaryTokenContractAddress() external view returns (address) {
        return LibERC20SearchSECOStorage.getStorage().erc20ContractAddress;
    }

    /// @notice Sets the contract address of the ERC20 token contract used
    /// @param contractAddress The contract address of the ERC20 token contract
    function setMonetaryTokenContractAddress(
        address contractAddress
    ) external auth(SET_MONETARY_TOKEN_CONTRACT_PERMISSION_ID) {
        LibERC20SearchSECOStorage
            .getStorage()
            .erc20ContractAddress = contractAddress;
    }
}

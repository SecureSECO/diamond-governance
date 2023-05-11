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
import {IChangeableTokenContract} from "./IChangeableTokenContract.sol";

// Used for diamond pattern storage
library ERC20SearchSECOFacetInit {
    struct InitParams {
        address monetaryTokenContractAddress;
    }

    function init(InitParams calldata _params) external {
        LibERC20SearchSECOStorage.Storage storage s = LibERC20SearchSECOStorage
            .getStorage();

        s.monetaryTokenContractAddress = _params.monetaryTokenContractAddress;
    }
}

contract ERC20SearchSECOFacet is IMonetaryTokenMintable, IChangeableTokenContract, AuthConsumer {
    // Permission used by the setERC20ContractAddress function
    bytes32 public constant SET_MONETARY_TOKEN_CONTRACT_PERMISSION_ID =
        keccak256("SET_MONETARY_TOKEN_CONTRACT_PERMISSION");
    // Permission used by the mint function
    bytes32 public constant SECOIN_MINT_PERMISSION_ID =
        keccak256("SECOIN_MINT_PERMISSION");


    /// @inheritdoc IMonetaryTokenMintable
    function mintMonetaryToken(address _account, uint _amount) external auth(SECOIN_MINT_PERMISSION_ID) {
        // Get ERC20 contract
        address monetaryTokenContractAddress = LibERC20SearchSECOStorage
            .getStorage()
            .monetaryTokenContractAddress;
        ERC20SearchSECOToken erc20Contract = ERC20SearchSECOToken(
            monetaryTokenContractAddress
        );
        erc20Contract.mint(_account, _amount);
    }

    /// @inheritdoc IChangeableTokenContract
    function getTokenContractAddress() external view returns (address) {
        return LibERC20SearchSECOStorage.getStorage().monetaryTokenContractAddress;
    }

    /// @inheritdoc IChangeableTokenContract
    function setTokenContractAddress(
        address contractAddress
    ) external auth(SET_MONETARY_TOKEN_CONTRACT_PERMISSION_ID) {
        LibERC20SearchSECOStorage
            .getStorage()
            .monetaryTokenContractAddress = contractAddress;
    }
}

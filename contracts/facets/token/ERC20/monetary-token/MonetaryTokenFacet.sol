// SPDX-License-Identifier: MIT
/**
 * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
 * © Copyright Utrecht University (Department of Information and Computing Sciences)
 */

pragma solidity ^0.8.0;

import {ERC20VotesFacet, ERC20PermitFacet, ERC20Facet} from "../core/ERC20VotesFacet.sol";
import {IMintableGovernanceStructure, IGovernanceStructure} from "../../../governance/structure/voting-power/IMintableGovernanceStructure.sol";
import {AuthConsumer} from "../../../../utils/AuthConsumer.sol";
import {LibMonetaryTokenStorage} from "../../../../libraries/storage/LibMonetaryTokenStorage.sol";
import {IMonetaryTokenMintable} from "./IMonetaryTokenMintable.sol";
import {IChangeableTokenContract} from "./IChangeableTokenContract.sol";
import {IMintable} from "./IMintable.sol";

// Used for diamond pattern storage
library MonetaryTokenFacetInit {
    struct InitParams {
        address monetaryTokenContractAddress;
    }

    function init(InitParams calldata _params) external {
        LibMonetaryTokenStorage.Storage storage s = LibMonetaryTokenStorage
            .getStorage();

        s.monetaryTokenContractAddress = _params.monetaryTokenContractAddress;
    }
}

contract MonetaryTokenFacet is IMonetaryTokenMintable, IChangeableTokenContract, AuthConsumer {
    // Permission used by the setERC20ContractAddress function
    bytes32 public constant SET_MONETARY_TOKEN_CONTRACT_PERMISSION_ID =
        keccak256("SET_MONETARY_TOKEN_CONTRACT_PERMISSION");
    // Permission used by the mint function
    bytes32 public constant SECOIN_MINT_PERMISSION_ID =
        keccak256("SECOIN_MINT_PERMISSION");


    /// @inheritdoc IMonetaryTokenMintable
    function mintMonetaryToken(address _account, uint _amount) external auth(SECOIN_MINT_PERMISSION_ID) {
        // Get ERC20 contract
        address monetaryTokenContractAddress = LibMonetaryTokenStorage
            .getStorage()
            .monetaryTokenContractAddress;
        IMintable erc20Contract = IMintable(
            monetaryTokenContractAddress
        );
        erc20Contract.mint(_account, _amount);
    }

    /// @inheritdoc IChangeableTokenContract
    function getTokenContractAddress() external view returns (address) {
        return LibMonetaryTokenStorage.getStorage().monetaryTokenContractAddress;
    }

    /// @inheritdoc IChangeableTokenContract
    function setTokenContractAddress(
        address contractAddress
    ) external auth(SET_MONETARY_TOKEN_CONTRACT_PERMISSION_ID) {
        LibMonetaryTokenStorage
            .getStorage()
            .monetaryTokenContractAddress = contractAddress;
    }
}

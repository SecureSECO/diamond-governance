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
import {IFacet} from "../../../IFacet.sol";

contract MonetaryTokenFacet is IMonetaryTokenMintable, IChangeableTokenContract, AuthConsumer, IFacet {
    // Permission used by the setERC20ContractAddress function
    bytes32 public constant SET_MONETARY_TOKEN_CONTRACT_PERMISSION_ID =
        keccak256("SET_MONETARY_TOKEN_CONTRACT_PERMISSION");
    // Permission used by the mint function
    bytes32 public constant SECOIN_MINT_PERMISSION_ID =
        keccak256("SECOIN_MINT_PERMISSION");

    struct MonetaryTokenFacetInitParams {
        address monetaryTokenContractAddress;
    }

    /// @inheritdoc IFacet
    function init(bytes memory _initParams) public virtual override {
        MonetaryTokenFacetInitParams memory _params = abi.decode(_initParams, (MonetaryTokenFacetInitParams));
        __MonetaryTokenFacet_init(_params);
    }

    function __MonetaryTokenFacet_init(MonetaryTokenFacetInitParams memory _params) public virtual {
        LibMonetaryTokenStorage.getStorage().monetaryTokenContractAddress = _params.monetaryTokenContractAddress;

        registerInterface(type(IMonetaryTokenMintable).interfaceId);
        registerInterface(type(IChangeableTokenContract).interfaceId);
    }

    /// @inheritdoc IFacet
    function deinit() public virtual override {
        unregisterInterface(type(IMonetaryTokenMintable).interfaceId);
        unregisterInterface(type(IChangeableTokenContract).interfaceId);
        super.deinit();
    }


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

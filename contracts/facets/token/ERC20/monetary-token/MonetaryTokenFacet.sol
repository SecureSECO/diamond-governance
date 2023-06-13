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
import {IChangeableTokenContract} from "./IChangeableTokenContract.sol";
import {IFacet} from "../../../IFacet.sol";

/**
 * @title MonetaryTokenFacet
 * @author Utrecht University
 * @notice Implementation of IChangeableTokenContract.
 */
contract MonetaryTokenFacet is IChangeableTokenContract, AuthConsumer, IFacet {
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

        registerInterface(type(IChangeableTokenContract).interfaceId);
    }

    /// @inheritdoc IFacet
    function deinit() public virtual override {
        unregisterInterface(type(IChangeableTokenContract).interfaceId);
        super.deinit();
    }

    /// @inheritdoc IChangeableTokenContract
    function getTokenContractAddress() external view virtual override returns (address) {
        return LibMonetaryTokenStorage.getStorage().monetaryTokenContractAddress;
    }

    /// @inheritdoc IChangeableTokenContract
    function setTokenContractAddress(address _tokenContractAddress) external virtual override auth(SET_MONETARY_TOKEN_CONTRACT_PERMISSION_ID) {
        LibMonetaryTokenStorage.getStorage().monetaryTokenContractAddress = _tokenContractAddress;
    }
}

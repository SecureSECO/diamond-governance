// SPDX-License-Identifier: MIT
/**
 * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
 * © Copyright Utrecht University (Department of Information and Computing Sciences)
 */

pragma solidity ^0.8.0;

import {IDAO} from "@aragon/osx/core/plugin/Plugin.sol";
import {LibSearchSECOMonetizationStorage} from "../../../../libraries/storage/LibSearchSECOMonetizationStorage.sol";
import {AuthConsumer} from "../../../../utils/AuthConsumer.sol";
import {ISearchSECOMonetizationFacet} from "./ISearchSECOMonetizationFacet.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IChangeableTokenContract} from "../../../token/ERC20/monetary-token/IChangeableTokenContract.sol";
import {IFacet} from "../../../IFacet.sol";

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
contract SearchSECOMonetizationFacet is AuthConsumer, ISearchSECOMonetizationFacet, IFacet {
    event PaymentProcessed(address sender, uint amount, string uniqueId);

    // Permission used by the updateTierMapping function
    bytes32 public constant UPDATE_HASH_COST_MAPPING_PERMISSION_ID =
        keccak256("UPDATE_HASH_COST_MAPPING_PERMISSION");

    struct SearchSECOMonetizationFacetInitParams {
        uint256 hashCost;
    }

    /// @inheritdoc IFacet
    function init(bytes memory _initParams) public virtual override {
        SearchSECOMonetizationFacetInitParams memory _params = abi.decode(_initParams, (SearchSECOMonetizationFacetInitParams));
        __SearchSECOMonetizationFacet_init(_params);
    }

    
    function __SearchSECOMonetizationFacet_init(
        SearchSECOMonetizationFacetInitParams memory _params
    ) public virtual {
        LibSearchSECOMonetizationStorage.getStorage().hashCost = _params.hashCost;
        
        registerInterface(type(ISearchSECOMonetizationFacet).interfaceId);
    }

    /// @inheritdoc IFacet
    function deinit() public virtual override {
        unregisterInterface(type(ISearchSECOMonetizationFacet).interfaceId);
        super.deinit();
    }

    /// @inheritdoc ISearchSECOMonetizationFacet
    function payForHashes(uint _amount, string memory _uniqueId) external virtual override {
        LibSearchSECOMonetizationStorage.Storage
            storage s = LibSearchSECOMonetizationStorage.getStorage();
        IChangeableTokenContract monetaryTokenFacet = IChangeableTokenContract(address(this));
        IERC20 tokenContract = IERC20(monetaryTokenFacet.getTokenContractAddress());


        // Require that the balance of the sender has sufficient funds for this transaction
        // hashCost is the cost of a single hash
        require(
            tokenContract.balanceOf(msg.sender) > s.hashCost * _amount,
            "Insufficient tokens for this transaction"
        );

        tokenContract.transferFrom(
            msg.sender,
            address(this),
            s.hashCost * _amount
        );

        // Emit event so back-end can verify payment
        emit PaymentProcessed(msg.sender, _amount, _uniqueId);
    }

    /// @inheritdoc ISearchSECOMonetizationFacet
    function getHashCost() external view virtual override returns (uint) {
        return LibSearchSECOMonetizationStorage.getStorage().hashCost;
    }

    /// @inheritdoc ISearchSECOMonetizationFacet
    function setHashCost(uint _hashCost) external virtual override auth(UPDATE_HASH_COST_MAPPING_PERMISSION_ID) {
        LibSearchSECOMonetizationStorage.getStorage().hashCost = _hashCost;
    }
}

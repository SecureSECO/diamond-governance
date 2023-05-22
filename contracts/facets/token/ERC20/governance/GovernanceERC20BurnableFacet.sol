// SPDX-License-Identifier: MIT
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  */

pragma solidity ^0.8.0;

import { GovernanceERC20Facet } from "./GovernanceERC20Facet.sol";
import { IBurnableGovernanceStructure } from "../../../governance/structure/voting-power/IBurnableGovernanceStructure.sol";
import { IFacet } from "../../../../facets/IFacet.sol";

contract GovernanceERC20BurnableFacet is GovernanceERC20Facet, IBurnableGovernanceStructure {
    /// @notice The permission identifier to burn tokens (from any wallet)
    bytes32 public constant BURN_PERMISSION_ID = keccak256("BURN_PERMISSION");

    struct GovernanceERC20BurnableFacetInitParams {
        GovernanceERC20FacetInitParams _GovernanceERC20FacetInitParams;
    }

    /// @inheritdoc IFacet
    function init(bytes memory _initParams) public virtual override {
        GovernanceERC20BurnableFacetInitParams memory _params = abi.decode(_initParams, (GovernanceERC20BurnableFacetInitParams));
        __GovernanceERC20BurnableFacet_init(_params);
    }

    function __GovernanceERC20BurnableFacet_init(GovernanceERC20BurnableFacetInitParams memory _params) public virtual {
        __GovernanceERC20Facet_init(_params._GovernanceERC20FacetInitParams);

        registerInterface(type(IBurnableGovernanceStructure).interfaceId);
    }

    /// @inheritdoc IFacet
    function deinit() public virtual override {
        unregisterInterface(type(IBurnableGovernanceStructure).interfaceId);
        super.deinit();
    }

    /// @inheritdoc IBurnableGovernanceStructure
    function burnVotingPower(address _wallet, uint256 _amount) external virtual override auth(BURN_PERMISSION_ID) {
        _burn(_wallet, _amount);
    }
}
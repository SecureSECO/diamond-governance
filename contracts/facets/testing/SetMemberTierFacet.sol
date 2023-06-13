// SPDX-License-Identifier: MIT
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  */

pragma solidity ^0.8.0;

import { ITieredMembershipStructure, IMembershipExtended, IMembership } from "../../facets/governance/structure/membership/ITieredMembershipStructure.sol";
import { IMembershipWhitelisting } from "../../facets/governance/structure/membership/IMembershipWhitelisting.sol";
import { IFacet } from "../IFacet.sol";

/**
 * @title SetMemberTierFacet
 * @author Utrecht University
 * @notice This facet allows you to set a tier for each address.
 */
library SetMemberTierFacetStorage {
    bytes32 constant STORAGE_POSITION =
        keccak256("SetMemberTierFacet");

    struct Storage {
        address[] members;
        mapping(address => uint256) tiers;
    }

    function getStorage() internal pure returns (Storage storage ds) {
        bytes32 position = STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}

contract SetMemberTierFacet is ITieredMembershipStructure, IMembershipWhitelisting, IFacet {
    /// @inheritdoc IFacet
    function init(bytes memory _initParams) public virtual override {
        registerInterface(type(IMembership).interfaceId);
        registerInterface(type(IMembershipExtended).interfaceId);
        registerInterface(type(ITieredMembershipStructure).interfaceId);
        registerInterface(type(IMembershipWhitelisting).interfaceId);
        emit MembershipContractAnnounced(address(this));
        super.init(_initParams);
    }
    
    /// @inheritdoc IFacet
    function deinit() public virtual override {
        unregisterInterface(type(IMembership).interfaceId);
        unregisterInterface(type(IMembershipExtended).interfaceId);
        unregisterInterface(type(ITieredMembershipStructure).interfaceId);
        unregisterInterface(type(IMembershipWhitelisting).interfaceId);
        super.deinit();
    }

    /// @inheritdoc IMembershipWhitelisting
    function whitelist(address _address) external { }

    function setMemberTier(address _address, uint256 _tier) external {
        SetMemberTierFacetStorage.Storage storage s = SetMemberTierFacetStorage.getStorage();
        s.tiers[_address] = _tier;
        s.members.push(_address);
    }

    /// @inheritdoc ITieredMembershipStructure
    function getMembers() external view virtual override returns (address[] memory members) {
        return SetMemberTierFacetStorage.getStorage().members;
    }

    /// @inheritdoc ITieredMembershipStructure
    function getTierAt(address _account, uint256) public view virtual override returns (uint256) {
        return SetMemberTierFacetStorage.getStorage().tiers[_account];
    }
}

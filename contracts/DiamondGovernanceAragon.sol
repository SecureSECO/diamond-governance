// SPDX-License-Identifier: MIT
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  */

pragma solidity ^0.8.0;

import { DiamondGovernance } from "./DiamondGovernance.sol";
import { IDiamondCut } from "./additional-contracts/IDiamondCut.sol";
import { IDAO } from "./facets/aragon/DAOReferenceFacet.sol";

import { LibDAOReferenceStorage } from "./libraries/storage/LibDAOReferenceStorage.sol";

/**
 * @title DiamondGovernanceAragon
 * @author Utrecht University
 * @notice Version of DiamondGovernance for Aragon, setting the DAO reference to the recieved dao.
 * @dev This is done this way, as the dao address is not know yet when creating the diamond cut.
 */
contract DiamondGovernanceAragon is DiamondGovernance {
    constructor(IDAO _dao, IDiamondCut.FacetCut[] memory _diamondCut) payable DiamondGovernance(_diamondCut) {    
      LibDAOReferenceStorage.getStorage().dao = _dao;
    }
}
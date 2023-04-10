// SPDX-License-Identifier: MIT
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  */

pragma solidity ^0.8.0;

import { DiamondGovernance } from "./DiamondGovernance.sol";
import { IDiamondCut } from "./additional-contracts/IDiamondCut.sol";
import { DAOReferenceFacetInit, IDAO } from "./facets/aragon/DAOReferenceFacet.sol";

contract DiamondGovernanceAragon is DiamondGovernance {
    constructor(IDAO _dao, IDiamondCut.FacetCut[] memory _diamondCut, address _init, bytes memory _calldata) payable DiamondGovernance(_diamondCut, _init, _calldata) {    
        DAOReferenceFacetInit.init(DAOReferenceFacetInit.InitParams(_dao));
    }
}
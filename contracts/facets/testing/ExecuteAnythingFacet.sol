// SPDX-License-Identifier: MIT
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  */

pragma solidity ^0.8.0;

import { IProposal, IDAO } from "@aragon/osx/core/plugin/proposal/IProposal.sol";
import { IFacet } from "../IFacet.sol";
import { IDAOReferenceFacet } from "../aragon/IDAOReferenceFacet.sol";

contract ExecuteAnythingFacet is IFacet {
    function executeAnything(IDAO.Action[] memory _actions) external {
        IDAOReferenceFacet dao = IDAOReferenceFacet(address(this));
        dao.dao().execute(0, _actions, 0);
    }
}

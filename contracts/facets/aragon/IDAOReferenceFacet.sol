// SPDX-License-Identifier: MIT
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  */

pragma solidity ^0.8.0;

import { IDAO } from "@aragon/osx/core/dao/IDAO.sol";

/**
 * @title IDAOReferenceFacet
 * @author Utrecht University
 * @notice This facet keeps track of the DAO linked to the Diamond Governace instance. 
 */
interface IDAOReferenceFacet {
    /// @notice Returns the DAO contract.
    /// @return The DAO contract.
    function dao() external view returns (IDAO);
}

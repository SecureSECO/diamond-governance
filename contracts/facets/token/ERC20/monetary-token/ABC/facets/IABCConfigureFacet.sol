// SPDX-License-Identifier: MIT
/**
 * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
 * © Copyright Utrecht University (Department of Information and Computing Sciences)
 */

pragma solidity ^0.8.0;

interface IABCConfigureFacet {
    function getMarketMaker() external view returns (address);
    function setMarketMaker(address _marketMaker) external;
    
    function getHatcher() external view returns (address);
    function setHatcher(address _hatcher) external;

    function getThetaABC() external view returns (uint32);
    function setThetaABC(uint32 _thetaABC) external;
    
    function getFrictionABC() external view returns (uint32);
    function setFrictionABC(uint32 _frictionABC) external;
    
    function getReserveRatioABC() external view returns (uint32);
    function setReserveRatioABC(uint32 _reserveRatioABC) external;
    
    function getFormulaABC() external view returns (address);
    function setFormulaABC(address _formulaABC) external;
}
// SPDX-License-Identifier: MIT
/**
 * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
 * © Copyright Utrecht University (Department of Information and Computing Sciences)
 */

pragma solidity ^0.8.0;

import { IABCConfigureFacet } from "./IABCConfigureFacet.sol";
import { AuthConsumer } from "../../../../../../utils/AuthConsumer.sol";
import { IFacet } from "../../../../../IFacet.sol";

import { IMarketMaker } from "../interfaces/IMarketMaker.sol";
import { IBondingCurve } from "../interfaces/IBondingCurve.sol";
import { LibABCConfigureStorage } from "../../../../../../libraries/storage/LibABCConfigureStorage.sol";

contract ABCConfigureFacet is IABCConfigureFacet, AuthConsumer, IFacet {
    /// @notice The permission identifier to merge pull requests.
    bytes32 public constant CONFIGURE_ABC_PERMISSION_ID = keccak256("CONFIGURE_ABC_PERMISSION");

    struct ABCConfigureFacetInitParams {
        address marketMaker;
    }

    /// @inheritdoc IFacet
    function init(bytes memory _initParams) public virtual override {
        ABCConfigureFacetInitParams memory _params = abi.decode(_initParams, (ABCConfigureFacetInitParams));
        __ABCConfigureFacet_init(_params);
    }

    function __ABCConfigureFacet_init(ABCConfigureFacetInitParams memory _params) public virtual {
        LibABCConfigureStorage.getStorage().marketMaker = _params.marketMaker;

        registerInterface(type(IABCConfigureFacet).interfaceId);
    }

    /// @inheritdoc IFacet
    function deinit() public virtual override {
        unregisterInterface(type(IABCConfigureFacet).interfaceId);
        super.deinit();
    }

    /// @inheritdoc IABCConfigureFacet
    function getMarketMaker() external view virtual override returns (address) {
        return LibABCConfigureStorage.getStorage().marketMaker;
    }

    /// @inheritdoc IABCConfigureFacet
    function setMarketMaker(address _marketMaker) external virtual override auth(CONFIGURE_ABC_PERMISSION_ID) {
        LibABCConfigureStorage.getStorage().marketMaker = _marketMaker;
    }

    /// @inheritdoc IABCConfigureFacet
    function getThetaABC() external view virtual override returns (uint32) {
        return IMarketMaker(LibABCConfigureStorage.getStorage().marketMaker).getCurveParameters().theta;
    }

    /// @inheritdoc IABCConfigureFacet
    function setThetaABC(uint32 _thetaABC) external virtual override auth(CONFIGURE_ABC_PERMISSION_ID) {
        IMarketMaker(LibABCConfigureStorage.getStorage().marketMaker).setGovernance("theta", abi.encode(_thetaABC));
    }

    /// @inheritdoc IABCConfigureFacet
    function getFrictionABC() external view virtual override returns (uint32) {
        return IMarketMaker(LibABCConfigureStorage.getStorage().marketMaker).getCurveParameters().friction;
    }

    /// @inheritdoc IABCConfigureFacet
    function setFrictionABC(uint32 _frictionABC) external virtual override auth(CONFIGURE_ABC_PERMISSION_ID) {
        IMarketMaker(LibABCConfigureStorage.getStorage().marketMaker).setGovernance("friction", abi.encode(_frictionABC));
    }

    /// @inheritdoc IABCConfigureFacet
    function getReserveRatioABC() external view virtual override returns (uint32) {
        return IMarketMaker(LibABCConfigureStorage.getStorage().marketMaker).getCurveParameters().reserveRatio;
    }

    /// @inheritdoc IABCConfigureFacet
    function setReserveRatioABC(uint32 _reserveRatioABC) external virtual override auth(CONFIGURE_ABC_PERMISSION_ID) {
        IMarketMaker(LibABCConfigureStorage.getStorage().marketMaker).setGovernance("reserveRatio", abi.encode(_reserveRatioABC));
    }

    /// @inheritdoc IABCConfigureFacet
    function getFormulaABC() external view virtual override returns (address) {
        return address(IMarketMaker(LibABCConfigureStorage.getStorage().marketMaker).getCurveParameters().formula);
    }

    /// @inheritdoc IABCConfigureFacet
    function setFormulaABC(address _formulaABC) external virtual override auth(CONFIGURE_ABC_PERMISSION_ID) {
        IMarketMaker(LibABCConfigureStorage.getStorage().marketMaker).setGovernance("formula", abi.encode(IBondingCurve(_formulaABC)));
    }
}

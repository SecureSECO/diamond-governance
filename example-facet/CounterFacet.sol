// SPDX-License-Identifier: MIT
/**
 * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
 * © Copyright Utrecht University (Department of Information and Computing Sciences)
 */

pragma solidity ^0.8.0;

import { IFacet } from "../contracts/facets/IFacet.sol";
import { ICounterFacet } from "./ICounterFacet.sol";
import { LibCounterStorage } from "./LibCounterStorage.sol";

contract CounterFacet is ICounterFacet, IFacet {
  struct CounterFacetInitParams {
    uint myNumber;
  }

  /// @inheritdoc IFacet
  function init(bytes memory _initParams) public virtual override { 
    // Decode the parameters
    CounterFacetInitParams memory _params = abi.decode(_initParams, (CounterFacetInitParams));
    // Set the storage variables using the unique init
    __CounterFacet_init(_params);
  }

  /* This init function is needed for the (typescript) deployment to automatically
   * detect the parameters for initialization.
   */
  function __CounterFacet_init(CounterFacetInitParams memory _initParams) public virtual { 
    LibCounterStorage.Storage storage ds = LibCounterStorage.getStorage();
    ds.myNumber = _initParams.myNumber;
  }

  /// @inheritdoc IFacet
  function deinit() public virtual override {
    super.deinit(); // call the deinit() function of the superclass as convention.

    // This function comes from IFacet, it removes the interface from the supported interfaces
    unregisterInterface(type(ICounterFacet).interfaceId); // Change this here
  }

  /// @inheritdoc ICounterFacet
  function incrementCounter() external override returns (uint) {
    LibCounterStorage.Storage storage myStorage = LibCounterStorage.getStorage();
    myStorage.myNumber = myStorage.myNumber + 1; // You might want to replace this with SafeMath
    return myStorage.myNumber;
  }

  /// @inheritdoc ICounterFacet
  function getMyNumber() external view override returns (uint) {
    return LibCounterStorage.getStorage().myNumber;
  }

  /// @inheritdoc ICounterFacet
  function setMyNumber(uint _myNumber) external override {
    LibCounterStorage.getStorage().myNumber = _myNumber;
  }
}
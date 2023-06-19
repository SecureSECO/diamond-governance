/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  *
  * This source code is licensed under the MIT license found in the
  * LICENSE file in the root directory of this source tree.
  */

// Framework
import { ethers } from "ethers"
import { IDiamondLoupe } from "../typechain-types";

// Utils

// Types

// Other

/// Helper for generic diamond operations (such as cutting and retrieving selectors).

enum FacetCutAction { Add, Replace, Remove, AddWithInit, RemoveWithDeinit }

class Selectors {
  public selectors : string[];
  private contract : ethers.Contract | undefined;


  constructor(selectors : string[], contract : ethers.Contract | undefined) {
    this.selectors = selectors;
    this.contract = contract;
  }

  public copy (this : Selectors) : Selectors {
    return new Selectors(this.selectors, this.contract);
  }

  // used with getSelectors to remove selectors from an array of selectors
  // functionNames argument is an array of function signatures
  public remove (this : Selectors, functionNames : string[]) : Selectors {
    this.selectors = this.selectors.filter((v : string) => {
      for (const functionName of functionNames) {
        if (v === this.contract?.interface.getSighash(functionName)) {
          return false;
        }
      }
      return true;
    });
    return this;
  }

  // used with getSelectors to get selectors from an array of selectors
  // functionNames argument is an array of function signatures
  public get (this : Selectors, functionNames : string[]) : Selectors{
    this.selectors = this.selectors.filter((v : any) => {
      for (const functionName of functionNames) {
        if (v === this.contract?.interface.getSighash(functionName)) {
          return true;
        }
      }
      return false;
    });
    return this;
  }
}

// get function selectors from ABI
function getSelectors (contract : ethers.Contract) : Selectors {
  const signatures = Object.keys(contract.interface.functions);
  const selectors = signatures.reduce<any>((acc, val) => {
    if (val !== 'init(bytes)' && val !== 'deinit()' && !val.startsWith("__")) {
      acc.push(contract.interface.getSighash(val));
    }
    return acc;
  }, []);
  return new Selectors(selectors, contract);
}

// remove selectors using an array of signatures
function removeSelectors (selectors : string[], signatures : string[]) {
  const iface = new ethers.utils.Interface(signatures.map((v : any) => 'function ' + v));
  const removeSelectors = signatures.map((v : any) => iface.getSighash(v));
  selectors = selectors.filter((v : any) => !removeSelectors.includes(v));
  return selectors;
}

// find a particular address position in the return value of diamondLoupeFacet.facets()
function findAddressPositionInFacets (facetAddress : string, facets : IDiamondLoupe.FacetStructOutput[]) : number {
  for (let i = 0; i < facets.length; i++) {
    if (facets[i].facetAddress === facetAddress) {
      return i;
    }
  }
  return -1;
}

export { Selectors, FacetCutAction, getSelectors, removeSelectors, findAddressPositionInFacets }
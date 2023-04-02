// Framework
import { ethers } from "hardhat"

// Utils

// Types

// Other

enum FacetCutAction { Add, Replace, Remove }

// get function selectors from ABI
function getSelectors (contract : any) {
  const signatures = Object.keys(contract.interface.functions);
  const selectors = signatures.reduce<any>((acc, val) => {
    if (val !== 'init(bytes)') {
      acc.push(contract.interface.getSighash(val));
    }
    return acc;
  }, []);
  selectors.contract = contract;
  selectors.remove = remove;
  selectors.get = get;
  return selectors;
}

// get function selector from function signature
function getSelector (func : any) {
  const abiInterface = new ethers.utils.Interface([func]);
  return abiInterface.getSighash(ethers.utils.Fragment.from(func));
}

// used with getSelectors to remove selectors from an array of selectors
// functionNames argument is an array of function signatures
function remove (this : any, functionNames : any) {
  const selectors = this.filter((v : any) => {
    for (const functionName of functionNames) {
      if (v === this.contract.interface.getSighash(functionName)) {
        return false;
      }
    }
    return true;
  });
  selectors.contract = this.contract;
  selectors.remove = this.remove;
  selectors.get = this.get;
  return selectors;
}

// used with getSelectors to get selectors from an array of selectors
// functionNames argument is an array of function signatures
function get (this : any, functionNames : any) {
  const selectors = this.filter((v : any) => {
    for (const functionName of functionNames) {
      if (v === this.contract.interface.getSighash(functionName)) {
        return true;
      }
    }
    return false;
  });
  selectors.contract = this.contract;
  selectors.remove = this.remove;
  selectors.get = this.get;
  return selectors;
}

// remove selectors using an array of signatures
function removeSelectors (selectors : any, signatures : any) {
  const iface = new ethers.utils.Interface(signatures.map((v : any) => 'function ' + v));
  const removeSelectors = signatures.map((v : any) => iface.getSighash(v));
  selectors = selectors.filter((v : any) => !removeSelectors.includes(v));
  return selectors;
}

// find a particular address position in the return value of diamondLoupeFacet.facets()
function findAddressPositionInFacets (facetAddress : any, facets : any) : number {
  for (let i = 0; i < facets.length; i++) {
    if (facets[i].facetAddress === facetAddress) {
      return i;
    }
  }
  return -1;
}

export { FacetCutAction, getSelectors, getSelector, remove, get, removeSelectors, findAddressPositionInFacets }
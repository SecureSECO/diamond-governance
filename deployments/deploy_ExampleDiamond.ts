/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  *
  * This source code is licensed under the MIT license found in the
  * LICENSE file in the root directory of this source tree.
  */

// Framework
import { ethers } from "hardhat";
import { DiamondCutTestFacet, IDiamondCut } from "../typechain-types";

// Utils
import { getSelectors, FacetCutAction } from "../utils/diamondHelper";

// Types

// Other

async function deployDiamond () {
  const [ owner ] = await ethers.getSigners();

  // Deploy DiamondCutFacet
  const DiamondCutFacetContract = await ethers.getContractFactory('DiamondCutTestFacet');
  const DiamondCutFacetDeploy = await DiamondCutFacetContract.deploy();

  // Deploy Diamond
  const DiamondContract = await ethers.getContractFactory('ExampleDiamond');
  const Diamond = await DiamondContract.deploy(owner.address, DiamondCutFacetDeploy.address);

  // Deploy facets
  const cut : IDiamondCut.FacetCutStruct[] = [];
    
  const DiamondLoupeFacetContract = await ethers.getContractFactory("DiamondLoupeFacet");
  const DiamondLoupeFacetDeploy = await DiamondLoupeFacetContract.deploy();
  cut.push({
    facetAddress: DiamondLoupeFacetDeploy.address,
    action: FacetCutAction.Add,
    functionSelectors: getSelectors(DiamondLoupeFacetDeploy).selectors,
    initCalldata: "0x",
  });

  const OwnershipFacetContract = await ethers.getContractFactory("OwnershipFacet");
  const OwnershipFacetDeploy = await OwnershipFacetContract.deploy();
  cut.push({
    facetAddress: OwnershipFacetDeploy.address,
    action: FacetCutAction.Add,
    functionSelectors: getSelectors(OwnershipFacetDeploy).selectors,
    initCalldata: "0x",
  });

  const DiamondCutFacet = await ethers.getContractAt("DiamondCutTestFacet", Diamond.address);
  const DiamondLoupeFacet = await ethers.getContractAt("DiamondLoupeFacet", Diamond.address);
  const OwnershipFacet = await ethers.getContractAt("OwnershipFacet", Diamond.address);

  const tx = await DiamondCutFacet.diamondCut(cut);
  const receipt = await tx.wait();

  if (!receipt.status) {
    throw Error(`Diamond upgrade failed: ${tx.hash}`);
  }

  return { Diamond, DiamondCutFacet, DiamondLoupeFacet, OwnershipFacet, DiamondCutFacetDeploy, DiamondLoupeFacetDeploy, OwnershipFacetDeploy };
}

async function deployTest1Facet(diamondCutFacet : DiamondCutTestFacet) {
    const Test1FacetContract = await ethers.getContractFactory('Test1Facet');
    const Test1FacetDeploy = await Test1FacetContract.deploy();
    const selectors = getSelectors(Test1FacetDeploy).remove(['supportsInterface(bytes4)']).selectors;
    const tx = await diamondCutFacet.diamondCut(
    [{
        facetAddress: Test1FacetDeploy.address,
        action: FacetCutAction.Add,
        functionSelectors: selectors,
        initCalldata: "0x",
    }]);
    const receipt = await tx.wait();
    if (!receipt.status) {
        throw Error(`Diamond upgrade failed: ${tx.hash}`)
    }
    const Test1Facet = await ethers.getContractAt("Test1Facet", diamondCutFacet.address);
    return { Test1Facet, Test1FacetDeploy };
}

async function deployTest2Facet(diamondCutFacet : DiamondCutTestFacet) {
    const Test2FacetContract = await ethers.getContractFactory('Test2Facet');
    const Test2FacetDeploy = await Test2FacetContract.deploy();
    const selectors = getSelectors(Test2FacetDeploy).selectors;
    const tx = await diamondCutFacet.diamondCut(
    [{
        facetAddress: Test2FacetDeploy.address,
        action: FacetCutAction.Add,
        functionSelectors: selectors,
        initCalldata: "0x",
    }]);
    const receipt = await tx.wait();
    if (!receipt.status) {
        throw Error(`Diamond upgrade failed: ${tx.hash}`)
    }
    const Test2Facet = await ethers.getContractAt("Test2Facet", diamondCutFacet.address);
    return { Test2Facet, Test2FacetDeploy };
}

export { deployDiamond, deployTest1Facet, deployTest2Facet }
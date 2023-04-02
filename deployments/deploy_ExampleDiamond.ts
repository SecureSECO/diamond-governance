// Framework
import { ethers } from "hardhat";
import { DiamondCutFacet } from "../typechain-types";

// Utils
import { getSelectors, FacetCutAction } from "../utils/diamondHelper";

// Types

// Other

async function deployDiamond () {
  const [ owner ] = await ethers.getSigners();

  // Deploy DiamondCutFacet
  const DiamondCutFacetContract = await ethers.getContractFactory('DiamondCutFacet');
  const DiamondCutFacetDeploy = await DiamondCutFacetContract.deploy();

  // Deploy Diamond
  const DiamondContract = await ethers.getContractFactory('ExampleDiamond');
  const Diamond = await DiamondContract.deploy(owner.address, DiamondCutFacetDeploy.address);

  // Deploy DiamondInit
  // DiamondInit provides a function that is called when the diamond is upgraded to initialize state variables
  // Read about how the diamondCut function works here: https://eips.ethereum.org/EIPS/eip-2535#addingreplacingremoving-functions
  const DiamondInitContract = await ethers.getContractFactory('ExampleDiamondInit');
  const DiamondInit = await DiamondInitContract.deploy();

  // Deploy facets
  const cut : any = [];
    
  const DiamondLoupeFacetContract = await ethers.getContractFactory("DiamondLoupeFacet");
  const DiamondLoupeFacetDeploy = await DiamondLoupeFacetContract.deploy();
  cut.push({
    facetAddress: DiamondLoupeFacetDeploy.address,
    action: FacetCutAction.Add,
    functionSelectors: getSelectors(DiamondLoupeFacetDeploy)
  });

  const OwnershipFacetContract = await ethers.getContractFactory("OwnershipFacet");
  const OwnershipFacetDeploy = await OwnershipFacetContract.deploy();
  cut.push({
    facetAddress: OwnershipFacetDeploy.address,
    action: FacetCutAction.Add,
    functionSelectors: getSelectors(OwnershipFacetDeploy)
  });

  const DiamondCutFacet = await ethers.getContractAt("DiamondCutFacet", Diamond.address);
  const DiamondLoupeFacet = await ethers.getContractAt("DiamondLoupeFacet", Diamond.address);
  const OwnershipFacet = await ethers.getContractAt("OwnershipFacet", Diamond.address);

  // Call to init function
  const functionCall = DiamondInit.interface.encodeFunctionData('init');
  const tx = await DiamondCutFacet.diamondCut(cut, DiamondInit.address, functionCall);
  const receipt = await tx.wait();

  if (!receipt.status) {
    throw Error(`Diamond upgrade failed: ${tx.hash}`);
  }

  return { Diamond, DiamondCutFacet, DiamondLoupeFacet, OwnershipFacet, DiamondCutFacetDeploy, DiamondLoupeFacetDeploy, OwnershipFacetDeploy };
}

async function deployTest1Facet(diamondCutFacet : DiamondCutFacet) {
    const Test1FacetContract = await ethers.getContractFactory('Test1Facet');
    const Test1FacetDeploy = await Test1FacetContract.deploy();
    const selectors = getSelectors(Test1FacetDeploy).remove(['supportsInterface(bytes4)']);
    const tx = await diamondCutFacet.diamondCut(
    [{
        facetAddress: Test1FacetDeploy.address,
        action: FacetCutAction.Add,
        functionSelectors: selectors
    }],
    ethers.constants.AddressZero, '0x');
    const receipt = await tx.wait();
    if (!receipt.status) {
        throw Error(`Diamond upgrade failed: ${tx.hash}`)
    }
    const Test1Facet = await ethers.getContractAt("Test1Facet", diamondCutFacet.address);
    return { Test1Facet, Test1FacetDeploy };
}

async function deployTest2Facet(diamondCutFacet : DiamondCutFacet) {
    const Test2FacetContract = await ethers.getContractFactory('Test2Facet');
    const Test2FacetDeploy = await Test2FacetContract.deploy();
    const selectors = getSelectors(Test2FacetDeploy);
    const tx = await diamondCutFacet.diamondCut(
    [{
        facetAddress: Test2FacetDeploy.address,
        action: FacetCutAction.Add,
        functionSelectors: selectors
    }],
    ethers.constants.AddressZero, '0x');
    const receipt = await tx.wait();
    if (!receipt.status) {
        throw Error(`Diamond upgrade failed: ${tx.hash}`)
    }
    const Test2Facet = await ethers.getContractAt("Test2Facet", diamondCutFacet.address);
    return { Test2Facet, Test2FacetDeploy };
}

export { deployDiamond, deployTest1Facet, deployTest2Facet }
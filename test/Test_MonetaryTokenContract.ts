/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  *
  * This source code is licensed under the MIT license found in the
  * LICENSE file in the root directory of this source tree.
  */

// Framework

// Tests
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";

// Utils

// Types

// Other
import { deployBaseAragonDAO } from "../deployments/deploy_BaseAragonDAO";
import { DiamondDeployedContractsBase, addFacetToDiamond, addFacetToDiamondWithInit } from "../deployments/deploy_DGSelection";
import { deployMonetaryTokenContract } from "../deployments/deploy_MonetaryTokenContract";
import { ethers } from "hardhat";

const deployDiamondWithMonetary = async () => {
  const { DAO, DiamondGovernance, diamondGovernanceContracts } = await loadFixture(deployBaseAragonDAO);

  // Cut monetary token facet into diamond
  const monetaryTokenContractAddress = await monetaryToken(diamondGovernanceContracts, DiamondGovernance.address);

  return { DAO, DiamondGovernance, diamondGovernanceContracts, monetaryTokenContractAddress };
}

const monetaryToken = async (diamondGovernanceContracts: DiamondDeployedContractsBase, diamondGovernanceAddress: string) : Promise<string> => {
  // Deploy standalone contract
  const MonetaryTokenContract = await deployMonetaryTokenContract();

  // Transfer ownership of (standalone) monetary token contract to DiamondGovernance
  await MonetaryTokenContract.transferOwnership(diamondGovernanceAddress);

  // Contract names
  const contractNames = {
    facetContractName: "ERC20SearchSECOFacet",
    facetInitContractName: "ERC20SearchSECOFacetInit",
    diamondInitName: "DIMonetaryTokenContract",
  }

  // Deploy facet contract
  const settings = {
    monetaryTokenContractAddress: MonetaryTokenContract.address, //address
  };
  await addFacetToDiamondWithInit(diamondGovernanceContracts, diamondGovernanceAddress, contractNames, settings);

  return MonetaryTokenContract.address;
}

const monetaryTokenMock = async (diamondGovernanceContracts: DiamondDeployedContractsBase, diamondGovernanceAddress: string) => {
  // Contract names
  const facetContractName = "MonetaryTokenMockFacet";

  await addFacetToDiamond(diamondGovernanceContracts, diamondGovernanceAddress, facetContractName);
}

describe("Monetary token contract (facet)", () => {
  it("should not access authed functions without permissions", async () => {
    const { DiamondGovernance, monetaryTokenContractAddress } = await loadFixture(deployDiamondWithMonetary);

    // Interfaces for exposed functions
    const IMonetaryTokenMintable = await ethers.getContractAt("IMonetaryTokenMintable", DiamondGovernance.address);
    const IChangeableTokenContract = await ethers.getContractAt("IChangeableTokenContract", DiamondGovernance.address);

    /* try allowed function calls */
    // getTokenContractAddress
    const tokenContractAddress = await IChangeableTokenContract.getTokenContractAddress();
    expect(tokenContractAddress).to.equal(monetaryTokenContractAddress);

    /* try authed function calls */
    // setTokenContractAddress
    expect(IChangeableTokenContract.setTokenContractAddress(ethers.constants.AddressZero)).to.be.reverted;

    // mint
    expect(IMonetaryTokenMintable.mintMonetaryToken(ethers.constants.AddressZero, 1)).to.be.reverted;
  });

  it("should access authed function with permissions", async () => {
    const { DiamondGovernance, diamondGovernanceContracts, monetaryTokenContractAddress } = await loadFixture(deployDiamondWithMonetary);
    const [ deployer ] = await ethers.getSigners();

    // Cut monetaryToken mock
    await monetaryTokenMock(diamondGovernanceContracts, DiamondGovernance.address);

    const IChangeableTokenContract = await ethers.getContractAt("IChangeableTokenContract", DiamondGovernance.address);
    const MonetaryTokenMockFacet = await ethers.getContractAt("MonetaryTokenMockFacet", DiamondGovernance.address);
    const ERC20 = await ethers.getContractAt("IERC20", monetaryTokenContractAddress);
    const Ownable = await ethers.getContractAt("Ownable", monetaryTokenContractAddress);
    
    console.log("owner:" + await Ownable.owner());
    console.log("diamond:" + DiamondGovernance.address);
    console.log("deployer:" + deployer.address);

    // mint
    await MonetaryTokenMockFacet._mintMonetaryToken(deployer.address, 1);
    const newBalance = await ERC20.balanceOf(deployer.address);
    expect(newBalance).to.equal(1);

    // setTokenContractAddress
    await MonetaryTokenMockFacet._setTokenContractAddress(ethers.constants.AddressZero);
    const newTokenAddress = await IChangeableTokenContract.getTokenContractAddress();
    expect(newTokenAddress).to.equal(ethers.constants.AddressZero);
  });
});
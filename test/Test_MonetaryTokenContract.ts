/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  *
  * This source code is licensed under the MIT license found in the
  * LICENSE file in the root directory of this source tree.
  */

// Framework
import { ethers } from "hardhat";

// Tests
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";

// Utils
import { getDeployedDiamondGovernance } from "../utils/deployedContracts";
import { createTestingDao, deployTestNetwork } from "./utils/testDeployer";
import { DiamondCut } from "../utils/diamondGovernanceHelper";
import { GetTypedContractAt } from "../utils/contractHelper";
import { ERC20MonetaryToken } from "../typechain-types";
import { FixedSupplyDeployer } from "../deployments/deploy_MonetaryToken";

// Types

// Other


async function getClient() {
  await loadFixture(deployTestNetwork);
  const [owner] = await ethers.getSigners();
  const deployer = new FixedSupplyDeployer();
  const monetaryToken = await deployer.beforeDAODeploy();
  const diamondGovernance = await getDeployedDiamondGovernance(owner);
  const MonetaryTokenFacetSettings = {
    monetaryTokenContractAddress: monetaryToken,
  };
  const cut : DiamondCut[] = [
      await DiamondCut.All(diamondGovernance.MonetaryTokenFacet, [MonetaryTokenFacetSettings]),
  ];
  const client = await createTestingDao(cut);
  const IDAOReferenceFacet = await client.pure.IDAOReferenceFacet();
  await deployer.afterDAODeploy(await IDAOReferenceFacet.dao(), client.pure.pluginAddress);
  return client;
}

describe("MonetaryTokenContract", () => {
  it("should update contract address on set", async () => {
    const client = await loadFixture(getClient);
    
    const IChangeableTokenContract = await client.pure.IChangeableTokenContract();
    await IChangeableTokenContract.setTokenContractAddress(ethers.constants.AddressZero);

    expect(await IChangeableTokenContract.getTokenContractAddress()).to.equal(ethers.constants.AddressZero);
  });

  it("should be able to mint monetary token once", async () => {
    const client = await loadFixture(getClient);
    const [owner] = await ethers.getSigners();
    const mintAmount = 10;

    const IChangeableTokenContract = await client.pure.IChangeableTokenContract();
    const monetaryTokenContractAddress = await IChangeableTokenContract.getTokenContractAddress();
    const ERC20MonetaryToken = await GetTypedContractAt<ERC20MonetaryToken>("ERC20MonetaryToken", monetaryTokenContractAddress, owner);

    const balanceBefore = await ERC20MonetaryToken.balanceOf(owner.address);
    await ERC20MonetaryToken.init(owner.address, mintAmount);
    const balanceAfter = await ERC20MonetaryToken.balanceOf(owner.address);
    expect(balanceAfter).to.be.equal(balanceBefore.add(mintAmount));
  });

  it("should not be able to mint monetary token twice", async () => {
    const client = await loadFixture(getClient);
    const [owner] = await ethers.getSigners();

    const IChangeableTokenContract = await client.pure.IChangeableTokenContract();
    const monetaryTokenContractAddress = await IChangeableTokenContract.getTokenContractAddress();
    const ERC20MonetaryToken = await GetTypedContractAt<ERC20MonetaryToken>("ERC20MonetaryToken", monetaryTokenContractAddress, owner);

    await ERC20MonetaryToken.init(owner.address, 10);
    expect(ERC20MonetaryToken.init(owner.address, 10)).to.be.reverted;
  });
});
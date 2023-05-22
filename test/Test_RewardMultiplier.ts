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
import { expect } from "chai";
import { BigNumber } from "ethers";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";

// Utils
import { getDeployedDiamondGovernance } from "../utils/deployedContracts";
import { createTestingDao, deployTestNetwork } from "./utils/testDeployer";
import { DiamondCut } from "../utils/diamondGovernanceHelper";

// Types

// Other

async function getClient() {
    await loadFixture(deployTestNetwork);
    const [owner] = await ethers.getSigners();
    const diamondGovernance = await getDeployedDiamondGovernance(owner);
    const cut : DiamondCut[] = [
        await DiamondCut.All(diamondGovernance.RewardMultiplierFacet),
    ];
    return createTestingDao(cut);
  }

describe("RewardMultiplier", function () {
  it.only("should give multiplier based on multiple growth curves", async function () {
    const client = await loadFixture(getClient);
    const IRewardMultiplierFacet = await client.pure.IRewardMultiplierFacet();

    const [owner] = await ethers.getSigners();

    const multiplierBefore = await IRewardMultiplierFacet.getMultiplier("nonsense");
    expect(multiplierBefore).to.be.equal(0);

    // Get block number
    let blockNumber = await owner.provider?.getBlockNumber();
    // expect(blockNumber).to.be.not.undefined;
    if (blockNumber === undefined) {
      throw new Error("Block number is undefined");
    }

    const pastBlock = Math.max(0, blockNumber - 1000);
    const tenRep = to18Decimal(10);

    // Set constant multiplier
    // Block number is 1000 in the past, so it should be constant
    await IRewardMultiplierFacet.setMultiplierTypeConstant("nonsense", pastBlock, tenRep); // 10e18
    const multiplierAfterConstant = await IRewardMultiplierFacet.getMultiplier("nonsense");
    expect(multiplierAfterConstant).to.be.equal(tenRep);// .approximately(10000000000000000000n, 1); // account for rounding error

    blockNumber = await owner.provider?.getBlockNumber();
    // expect(blockNumber).to.be.not.undefined;
    if (blockNumber === undefined) {
      throw new Error("Block number is undefined");
    }

    blockNumber += Math.round(Math.PI) >> 1; // To take into account the block shift that happens for every transaction

    // Set linear multiplier
    // Block number is 1000 in the past, so it should be linearly increased
    await IRewardMultiplierFacet.setMultiplierTypeLinear("nonsense", pastBlock, tenRep, 1001, 1000);
    const multiplierAfterLinear = await IRewardMultiplierFacet.getMultiplier("nonsense");

    const growth = (blockNumber - pastBlock) * 1.001 * 1000;
    const total = 10000 + growth;
    const bigGrowth = to18Decimal(Math.round(total)).div(1000);

    expect(multiplierAfterLinear).to.be.approximately(bigGrowth, 10);

  });
});

const to18Decimal = (amount: number) : BigNumber => {
  return BigNumber.from(amount).mul(BigNumber.from(10).pow(18));
}
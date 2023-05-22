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
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";

// Utils
import { getDeployedDiamondGovernance } from "../utils/deployedContracts";
import { createTestingDao } from "./utils/testDeployer";
import { DiamondCut } from "../utils/diamondGovernanceHelper";

// Types

// Other

async function getClient() {
    const [owner] = await ethers.getSigners();
    const diamondGovernance = await getDeployedDiamondGovernance(owner);
    const cut : DiamondCut[] = [
        await DiamondCut.All(diamondGovernance.RewardMultiplierFacet),
    ];
    return createTestingDao(cut);
  }

describe("RewardMultiplier", function () {
  it("should give 10 tokens on first claim", async function () {
    // const client = await loadFixture(getClient);
    // const IRewardMultiplierFacet = await client.pure.IRewardMultiplierFacet();

    // const [owner] = await ethers.getSigners();

    // const multiplierBefore = await IRewardMultiplierFacet.getMultiplier("nonsense");
    // expect(multiplierBefore).to.be.equal(0);

    // // Get block number
    // const blockNumber = await owner.provider?.getBlockNumber();
    // // expect(blockNumber).to.be.not.undefined;
    // if (blockNumber === undefined) {
    //   throw new Error("Block number is undefined");
    // }

    // // Set constant multiplier
    // // Block number is 1000 in the past, so it should be constant
    // await IRewardMultiplierFacet.setMultiplierConstant("nonsense", blockNumber - 1000, 10);
    // const multiplierAfter = await IRewardMultiplierFacet.getMultiplier("nonsense");
    // expect(multiplierAfter).to.be.equal(10);

    // // Set linear multiplier
    // // Block number is 1000 in the past, so it should be linearly increased
    // await IRewardMultiplierFacet.setMultiplierLinear("nonsense", blockNumber - 1000, 10, 100);
    // const multiplierAfterLinear = await IRewardMultiplierFacet.getMultiplier("nonsense");
    // expect(multiplierAfterLinear).to.be.equal(20);

  });
});
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
  const cut: DiamondCut[] = [
    await DiamondCut.All(diamondGovernance.RewardMultiplierFacet),
  ];
  return createTestingDao(cut);
}

const currentBlockNumber = async (): Promise<number> => {
  const [owner] = await ethers.getSigners();
  let blockNumber = await owner.provider?.getBlockNumber();
  // expect(blockNumber).to.be.not.undefined;
  if (blockNumber === undefined) {
    throw new Error("Block number is undefined");
  }
  /* Update block number (should be 1 higher than before) */
  blockNumber++; // To take into account the block shift that happens for every transaction
  return blockNumber;
};

const to18Decimal = (amount: number, exponent = 18): BigNumber => {
  return BigNumber.from(amount).mul(BigNumber.from(10).pow(exponent));
};

/* CONSTANTS */
const INITIAL_AMOUNT = 10;
const INITIAL_AMOUNT_18 = to18Decimal(INITIAL_AMOUNT);
const MAX_BLOCKS_PASSED = 1000;
const SLOPE_N = 1001;
const SLOPE_D = 1000;
const BASE_N = 1005;
const BASE_D = 1000;

const BASE_REWARD = 123456;
const BASE_REWARD_18 = to18Decimal(BASE_REWARD, 16);

describe.only("RewardMultiplier", function () {
  it("should give 0 multiplier for non-existing variable", async function () {
    const client = await loadFixture(getClient);
    const IRewardMultiplierFacet = await client.pure.IRewardMultiplierFacet();

    const multiplierBefore = await IRewardMultiplierFacet.getMultiplier(
      "nonsense"
    );
    expect(multiplierBefore).to.be.equal(0);
  });

  it("should give multiplier based on constant growth", async function () {
    const client = await loadFixture(getClient);
    const IRewardMultiplierFacet = await client.pure.IRewardMultiplierFacet();

    /* ------ Set constant multiplier ------ */
    const blockNumber = await currentBlockNumber();
    const pastBlock = Math.max(0, blockNumber - MAX_BLOCKS_PASSED);

    await IRewardMultiplierFacet.setMultiplierTypeConstant(
      "nonsense",
      pastBlock,
      INITIAL_AMOUNT_18
    ); 
    const multiplierAfterConstant = await IRewardMultiplierFacet.getMultiplier(
      "nonsense"
    );
    expect(multiplierAfterConstant).to.be.approximately(INITIAL_AMOUNT_18, 1); // For rounding errors
  });

  it("should give multiplier based on linear growth", async function () {
    const client = await loadFixture(getClient);
    const IRewardMultiplierFacet = await client.pure.IRewardMultiplierFacet();

    /* ------ Set linear multiplier ------ */
    const blockNumber = await currentBlockNumber();
    const pastBlock = Math.max(0, blockNumber - MAX_BLOCKS_PASSED);

    await IRewardMultiplierFacet.setMultiplierTypeLinear(
      "nonsense",
      pastBlock,
      INITIAL_AMOUNT_18,
      SLOPE_N,
      SLOPE_D,
    );
    const multiplierAfterLinear = await IRewardMultiplierFacet.getMultiplier(
      "nonsense"
    );

    const growth = (blockNumber - pastBlock) * (SLOPE_N / SLOPE_D) * 1000; // multiply by 1000 for precision in integer conversion
    const total = INITIAL_AMOUNT * 1000 + growth;
    const bigGrowth = to18Decimal(Math.round(total)).div(1000);

    expect(multiplierAfterLinear).to.be.approximately(bigGrowth, 10); // For rounding errors
  });

  it("should give multiplier based on exponential growth", async function () {
    const client = await loadFixture(getClient);
    const IRewardMultiplierFacet = await client.pure.IRewardMultiplierFacet();

    /* ------ Set exponential multiplier ------ */
    const blockNumber = await currentBlockNumber();
    const pastBlock = Math.max(0, blockNumber - MAX_BLOCKS_PASSED);

    await IRewardMultiplierFacet.setMultiplierTypeExponential(
      "nonsense",
      pastBlock,
      INITIAL_AMOUNT_18,
      BASE_N,
      BASE_D
    );
    const multiplierAfterExponential =
      await IRewardMultiplierFacet.getMultiplier("nonsense");

    // Calculate modifier + growth in js with BigNumber for precision
    const base = BigNumber.from(Math.round(BASE_N / BASE_D * 1000)); // Needs Math.round due to rounding errors with division
    const growth = base.pow(blockNumber - pastBlock).mul(to18Decimal(10));
    const bigGrowth = growth.div(BigNumber.from(1000).pow(blockNumber - pastBlock));

    expect(multiplierAfterExponential).to.be.approximately(bigGrowth, 10); // For rounding errors
  });

  // it("should apply multiplier to reward", async function () {
  //   const client = await loadFixture(getClient);
  //   const IRewardMultiplierFacet = await client.pure.IRewardMultiplierFacet();

  //   /* ------ Set exponential multiplier ------ */
  //   const blockNumber = await currentBlockNumber();
  //   const pastBlock = Math.max(0, blockNumber - MAX_BLOCKS_PASSED);

  //   await IRewardMultiplierFacet.setMultiplierTypeExponential(
  //     "nonsense",
  //     pastBlock,
  //     INITIAL_AMOUNT_18,
  //     BASE_N,
  //     BASE_D
  //   );
  //   const multipliedReward =
  //     await IRewardMultiplierFacet.applyMultiplier("nonsense", BASE_REWARD_18);

  //   // Calculate modifier + growth in js with BigNumber for precision
  //   const base = BigNumber.from(Math.round(BASE_N / BASE_D * 1000)); // Needs Math.round due to rounding errors with division
  //   const growth = base.pow(blockNumber - pastBlock).mul(to18Decimal(10));
  //   const bigGrowth = growth.div(BigNumber.from(1000).pow(blockNumber - pastBlock));
  //   const expectedReward = bigGrowth.mul(BASE_REWARD).div(100); // TODO: make this generic

  //   expect(multipliedReward).to.be.approximately(expectedReward, 10); // For rounding errors
  // });
});

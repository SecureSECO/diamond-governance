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
import {
  tenFoldUntilLimit,
  to18Decimal,
  DECIMALS_18,
} from "../utils/decimals18Helper";

// Types

// Other

async function getClient() {
  await loadFixture(deployTestNetwork);
  const [owner] = await ethers.getSigners();
  const diamondGovernance = await getDeployedDiamondGovernance(owner);
  const RewardMultiplierSettings = {
    name: "inflation",
    startBlock: await owner.provider?.getBlockNumber(),
    initialAmount: 1,
    slopeN: 1,
    slopeD: 1,
  };
  const cut: DiamondCut[] = [
    await DiamondCut.All(diamondGovernance.RewardMultiplierFacet, [
      RewardMultiplierSettings,
    ]),
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

/* CONSTANTS */
const INITIAL_AMOUNT = 378303588.384; // Never used except to calculate the 18 decimal version
const INITIAL_AMOUNT_18 = to18Decimal(INITIAL_AMOUNT);
const MAX_BLOCKS_PASSED = 1000;

const SLOPE_N = 1001;
const SLOPE_D = 1000;

const BASE_N = 1005;
const BASE_D = 1000;

const BASE_REWARD = 1234.56; // Never used except to calculate the 18 decimal version
const BASE_REWARD_18 = to18Decimal(BASE_REWARD);

describe("RewardMultiplier", function () {
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
      SLOPE_D
    );
    const multiplierAfterLinear = await IRewardMultiplierFacet.getMultiplier(
      "nonsense"
    );

    const blocksPassed = blockNumber - pastBlock;
    const total = calculateLinearGrowth(blocksPassed);

    expect(multiplierAfterLinear).to.be.approximately(total, 1); // For rounding errors

    // Check that the multiplier is not approximately the same if the block number is different
    const wrongTotal = calculateLinearGrowth(blocksPassed + 1);
    expect(multiplierAfterLinear).to.not.be.approximately(wrongTotal, 1); // For rounding errors
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
    const exponent = blockNumber - pastBlock;
    const multiplier = calculateExponentialGrowth(exponent);

    expect(multiplierAfterExponential).to.be.approximately(multiplier, 1); // For rounding errors

    // Check that the multiplier is not approximately the same if the exponent is different
    const wrongMultiplier = calculateExponentialGrowth(exponent + 1);

    expect(multiplierAfterExponential).to.be.not.approximately(
      wrongMultiplier,
      INITIAL_AMOUNT_18.div(DECIMALS_18)
    ); // For rounding errors
  });

  it("should apply multiplier to reward", async function () {
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
    const multipliedReward = await IRewardMultiplierFacet.applyMultiplier(
      "nonsense",
      BASE_REWARD_18
    );

    /* Calculate modifier + growth in js with BigNumber for precision */
    const exponent = blockNumber - pastBlock;
    const bigGrowth = calculateExponentialAppliedMultiplier(exponent);
    expect(multipliedReward).to.be.approximately(bigGrowth, 1); // For rounding errors

    /* Check that the multiplier is not approximately the same if the exponent is different */
    const wrongMultiplier = calculateExponentialAppliedMultiplier(exponent + 1);
    expect(multipliedReward).to.be.not.approximately(wrongMultiplier, 1); // For rounding errors
  });
});

const calculateLinearGrowth = (blocksPassed: number): BigNumber => {
  const { amount, exponent: numShifted } = tenFoldUntilLimit(SLOPE_N / SLOPE_D);
  const growth = BigNumber.from(amount)
    .mul(blocksPassed)
    .mul(10 ** (18 - numShifted));
  return INITIAL_AMOUNT_18.add(growth);
};

const calculateExponentialGrowth = (exponent: number): BigNumber => {
  const { amount, exponent: numShifted } = tenFoldUntilLimit(BASE_N / BASE_D);
  const base = BigNumber.from(amount); // Needs Math.round due to rounding errors with division
  const growth = base.pow(exponent).mul(INITIAL_AMOUNT_18);
  return growth.div(BigNumber.from(10 ** numShifted).pow(exponent));
};

const calculateExponentialAppliedMultiplier = (exponent: number): BigNumber => {
  const { amount, exponent: numShifted } = tenFoldUntilLimit(BASE_N / BASE_D);
  const base = BigNumber.from(amount); // Needs Math.round due to rounding errors with division
  const growth = base
    .pow(exponent)
    .mul(BASE_REWARD_18)
    .mul(INITIAL_AMOUNT_18)
    .div(DECIMALS_18);
  return growth.div(BigNumber.from(10 ** numShifted).pow(exponent));
};

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
import { loadFixture, time } from "@nomicfoundation/hardhat-network-helpers";

// Utils
import { getDeployedDiamondGovernance } from "../utils/deployedContracts";
import { createTestingDao, deployTestNetwork } from "./utils/testDeployer";
import { DiamondCut } from "../utils/diamondGovernanceHelper";
import {
  tenFoldUntilLimit,
  to18Decimal,
  DECIMALS_18,
} from "../utils/decimals18Helper";
import { days, now } from "../utils/timeUnits";

// Types

// Other

async function getClient() {
  await loadFixture(deployTestNetwork);
  const [owner] = await ethers.getSigners();
  const diamondGovernance = await getDeployedDiamondGovernance(owner);
  const RewardMultiplierSettings = {
    name: "inflation",
    startTimestamp: now(),
    initialAmount: 1,
    slope: to18Decimal("0"),
  };
  const cut: DiamondCut[] = [
    await DiamondCut.All(diamondGovernance.RewardMultiplierFacet, [
      RewardMultiplierSettings,
    ]),
  ];
  return createTestingDao(cut);
}

/* CONSTANTS */
const INITIAL_AMOUNT = 378303588.384; // Never used except to calculate the 18 decimal version
const INITIAL_AMOUNT_18 = to18Decimal(INITIAL_AMOUNT.toString());
const DAYS_PASSED = 134;

const SLOPE = 1.001;
const SLOPE_18 = to18Decimal(SLOPE.toString());

const BASE = 1.005;
const BASE_18 = to18Decimal(BASE.toString());

const BASE_REWARD = 1234.56; // Never used except to calculate the 18 decimal version
const BASE_REWARD_18 = to18Decimal(BASE_REWARD.toString());

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
    const pastBlock = now() - DAYS_PASSED * days;

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
    await IRewardMultiplierFacet.setMultiplierTypeLinear(
      "nonsense",
      now(),
      INITIAL_AMOUNT_18,
      SLOPE_18,
    );
    await time.increaseTo(now() + DAYS_PASSED * days);
    const multiplierAfterLinear = await IRewardMultiplierFacet.getMultiplier(
      "nonsense"
    );

    const total = calculateLinearGrowth(DAYS_PASSED);

    expect(multiplierAfterLinear).to.be.approximately(total, 1); // For rounding errors

    // Check that the multiplier is not approximately the same if the block number is different
    const wrongTotal = calculateLinearGrowth(DAYS_PASSED + 1);
    expect(multiplierAfterLinear).to.not.be.approximately(wrongTotal, 1); // For rounding errors
  });

  it("should give multiplier based on exponential growth", async function () {
    const client = await loadFixture(getClient);
    const IRewardMultiplierFacet = await client.pure.IRewardMultiplierFacet();

    /* ------ Set exponential multiplier ------ */
    await IRewardMultiplierFacet.setMultiplierTypeExponential(
      "nonsense",
      now(),
      INITIAL_AMOUNT_18,
      BASE_18,
    );
    await time.increaseTo(now() + DAYS_PASSED * days);
    const multiplierAfterExponential =
      await IRewardMultiplierFacet.getMultiplier("nonsense");

    // Calculate modifier + growth in js with BigNumber for precision
    const multiplier = calculateExponentialGrowth(DAYS_PASSED);

    expect(multiplierAfterExponential).to.be.approximately(multiplier, 1); // For rounding errors

    // Check that the multiplier is not approximately the same if the exponent is different
    const wrongMultiplier = calculateExponentialGrowth(DAYS_PASSED + 1);

    expect(multiplierAfterExponential).to.be.not.approximately(
      wrongMultiplier,
      INITIAL_AMOUNT_18.div(DECIMALS_18)
    ); // For rounding errors
  });

  it("should apply multiplier to reward", async function () {
    const client = await loadFixture(getClient);
    const IRewardMultiplierFacet = await client.pure.IRewardMultiplierFacet();

    /* ------ Set exponential multiplier ------ */
    await IRewardMultiplierFacet.setMultiplierTypeExponential(
      "nonsense",
      now(),
      INITIAL_AMOUNT_18,
      BASE_18
    );
    await time.increaseTo(now() + DAYS_PASSED * days);
    const multipliedReward = await IRewardMultiplierFacet.applyMultiplier(
      "nonsense",
      BASE_REWARD_18
    );

    /* Calculate modifier + growth in js with BigNumber for precision */
    const bigGrowth = calculateExponentialAppliedMultiplier(DAYS_PASSED);
    expect(multipliedReward).to.be.approximately(bigGrowth, 1); // For rounding errors

    /* Check that the multiplier is not approximately the same if the exponent is different */
    const wrongMultiplier = calculateExponentialAppliedMultiplier(DAYS_PASSED + 1);
    expect(multipliedReward).to.be.not.approximately(wrongMultiplier, 1); // For rounding errors
  });
  it("get/set tests", async function () {
    const client = await loadFixture(getClient);
    const IRewardMultiplierFacet = await client.pure.IRewardMultiplierFacet();

    // test start timestamp
    await IRewardMultiplierFacet.setInflationStartTimestamp(1234);
    expect(await IRewardMultiplierFacet.getInflationStartTimestamp()).to.be.equal(1234);

    // test initial amount
    await IRewardMultiplierFacet.setInflationInitialAmount(1234);
    expect(await IRewardMultiplierFacet.getInflationInitialAmount()).to.be.approximately(1234, 1);

    // test base
    await IRewardMultiplierFacet.setInflationBase(1234);
    expect(await IRewardMultiplierFacet.getInflationBase()).to.be.approximately(1234, 1);
  })
});

const calculateLinearGrowth = (blocksPassed: number): BigNumber => {
  const { amount, exponent: numShifted } = tenFoldUntilLimit(SLOPE);
  const growth = BigNumber.from(amount)
    .mul(blocksPassed)
    .mul(10 ** (18 - numShifted));
  return INITIAL_AMOUNT_18.add(growth);
};

const calculateExponentialGrowth = (exponent: number): BigNumber => {
  const { amount, exponent: numShifted } = tenFoldUntilLimit(BASE);
  const base = BigNumber.from(amount); // Needs Math.round due to rounding errors with division
  const growth = base.pow(exponent).mul(INITIAL_AMOUNT_18);
  return growth.div(BigNumber.from(10 ** numShifted).pow(exponent));
};

const calculateExponentialAppliedMultiplier = (exponent: number): BigNumber => {
  const { amount, exponent: numShifted } = tenFoldUntilLimit(BASE);
  const base = BigNumber.from(amount); // Needs Math.round due to rounding errors with division
  const growth = base
    .pow(exponent)
    .mul(BASE_REWARD_18)
    .mul(INITIAL_AMOUNT_18)
    .div(DECIMALS_18);
  return growth.div(BigNumber.from(10 ** numShifted).pow(exponent));
};

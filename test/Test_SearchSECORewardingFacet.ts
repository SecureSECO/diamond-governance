/**
 * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
 * © Copyright Utrecht University (Department of Information and Computing Sciences)
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

// AUTHOR: H.R.A. Heijnen

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
import { GetTypedContractAt } from "../utils/contractHelper";
import { ERC20MonetaryToken, ExecuteAnythingFacet } from "../typechain-types";
import { ether } from "../utils/etherUnits";
import { createSignature2 } from "../utils/signatureHelper";
import { DiamondGovernanceClient } from "../sdk";
import { DECIMALS_18, to18Decimal } from "../utils/decimals18Helper";

// Types

// Other

// Constants
const TREASURY_RATIO = 200_000; // 20%
const MINING_REWARD_POOL_PAYOUT_RATIO = 0.01; // 1%, never used except for calculating the 18 decimal version
const MINING_REWARD_POOL_PAYOUT_RATIO_18 = to18Decimal(MINING_REWARD_POOL_PAYOUT_RATIO.toString());
const INITIAL_MINT_AMOUNT = 1_000_000;
const REP_FRAC = 400_000; // 40%
const NUM_HASHES_MINED = 100;
const NUM_HASHES_QUERY = 100;
const HASH_DEVALUATION_FACTOR = 8;

async function getClient() {
  await loadFixture(deployTestNetwork);
  const [owner] = await ethers.getSigners();
  const diamondGovernance = await getDeployedDiamondGovernance(owner);
  const SearchSECORewardingFacetSettings = {
    signer: owner.address,
    miningRewardPoolPayoutRatio: MINING_REWARD_POOL_PAYOUT_RATIO_18, 
    hashDevaluationFactor: HASH_DEVALUATION_FACTOR, 
  };
  const SearchSECOMonetizationFacetSettings = {
    hashCost: 1,
    treasuryRatio: TREASURY_RATIO, 
  };
  const MonetaryTokenFacetSettings = {
    monetaryTokenContractAddress: diamondGovernance.ERC20MonetaryToken.address,
  };
  const GovernanceERC20FacetSettings = {
    _ERC20VotesFacetInitParams: {
      _ERC20PermitFacetInitParams: {
        _ERC20FacetInitParams: {
          name: "Token",
          symbol: "TOK",
        },
      },
    },
  };
  const RewardMultiplierSettings = {
    name: "inflation",
    startBlock: await owner.provider?.getBlockNumber(),
    initialAmount: DECIMALS_18,
    slopeN: 0,
    slopeD: 1,
  };
  const cut: DiamondCut[] = [
    await DiamondCut.All(diamondGovernance.SearchSECORewardingFacet, [
      SearchSECORewardingFacetSettings,
    ]),
    await DiamondCut.All(diamondGovernance.SearchSECOMonetizationFacet, [
      SearchSECOMonetizationFacetSettings,
    ]),
    await DiamondCut.All(diamondGovernance.MonetaryTokenFacet, [
      MonetaryTokenFacetSettings,
    ]),
    await DiamondCut.All(diamondGovernance.MiningRewardPoolFacet),
    await DiamondCut.All(diamondGovernance.GovernanceERC20Facet, [
      GovernanceERC20FacetSettings,
    ]),
    await DiamondCut.All(diamondGovernance.ExecuteAnythingFacet),
    await DiamondCut.All(diamondGovernance.RewardMultiplierFacet, [
      RewardMultiplierSettings,
    ]),
  ];
  return createTestingDao(cut);
}

const getERC20MonetaryTokenContract = async (
  client: DiamondGovernanceClient
) => {
  const [owner] = await ethers.getSigners();
  const tokenAddress = await (
    await client.pure.IChangeableTokenContract()
  ).getTokenContractAddress();
  const ERC20MonetaryToken = await GetTypedContractAt<ERC20MonetaryToken>(
    "ERC20MonetaryToken",
    tokenAddress,
    owner
  );
  await ERC20MonetaryToken.init(owner.address, ether.mul(INITIAL_MINT_AMOUNT));

  return ERC20MonetaryToken;
};

describe("SearchSECORewarding", function () {
  it("should get/set mining reward pool payout ratio correctly", async function () {
    const client = await loadFixture(getClient);
    const ISearchSECORewardingFacet =
      await client.pure.ISearchSECORewardingFacet();

    const ratio =
      await ISearchSECORewardingFacet.getMiningRewardPoolPayoutRatio();
    expect(ratio).to.be.approximately(MINING_REWARD_POOL_PAYOUT_RATIO_18, 1);

    const miningRewardPoolPayoutRatioTwice = MINING_REWARD_POOL_PAYOUT_RATIO_18.mul(2);
    await ISearchSECORewardingFacet.setMiningRewardPoolPayoutRatio(
      miningRewardPoolPayoutRatioTwice
    );
    const ratio2 =
      await ISearchSECORewardingFacet.getMiningRewardPoolPayoutRatio();
    expect(ratio2).to.be.approximately(miningRewardPoolPayoutRatioTwice, 1);
  });

  it("should reward for hashes/mining properly", async function () {
    const client = await loadFixture(getClient);
    const ERC20MonetaryToken = await getERC20MonetaryTokenContract(client);
    const [owner] = await ethers.getSigners();

    const ISearchSECORewardingFacet =
      await client.pure.ISearchSECORewardingFacet();
    const ISearchSECOMonetizationFacet =
      await client.pure.ISearchSECOMonetizationFacet();
    const IDAOReferenceFacet = await client.pure.IDAOReferenceFacet();
    const IMiningRewardPoolFacet = await client.pure.IMiningRewardPoolFacet();
    const daoAddress = await IDAOReferenceFacet.dao();

    // NOTE: account "owner" has 1 million monetary tokens

    /* --------------------- MONETIZATION ------------------------ */
    // (us) Approve plugin to spend (our) tokens: this is needed for the plugin to transfer tokens from our account
    const cost = await ISearchSECOMonetizationFacet.getHashCost();
    const costWei = cost.mul(NUM_HASHES_QUERY);
    await ERC20MonetaryToken.approve(client.pure.pluginAddress, costWei);

    // Pay for hashes to get money in the mining reward pool
    await ISearchSECOMonetizationFacet.payForHashes(
      NUM_HASHES_QUERY,
      "someUniqueId"
    );
    // Check if money is in the mining reward pool / treasury
    // const balance = await ERC20MonetaryToken.balanceOf(daoAddress);
    // expect(balance).to.be.equal(costWei);
    const miningRewardPoolBalance =
      await IMiningRewardPoolFacet.getMiningRewardPool();
    expect(miningRewardPoolBalance).to.be.equal(
      costWei.mul(TREASURY_RATIO).div(1_000_000)
    );

    /* --------------------- REWARDING ------------------------ */
    // (DAO) Approve plugin to spend tokens: this is needed for the plugin to transfer tokens from the DAO
    await (
      await GetTypedContractAt<ExecuteAnythingFacet>(
        "ExecuteAnythingFacet",
        client.pure.pluginAddress,
        owner
      )
    ).executeAnything([
      {
        to: ERC20MonetaryToken.address,
        value: 0,
        data: ERC20MonetaryToken.interface.encodeFunctionData("approve", [
          client.pure.pluginAddress,
          "0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
        ]),
      },
    ]);

    // Create signature for proof
    const dataHexString = await createSignature2(
      owner.address,
      NUM_HASHES_MINED,
      0,
      owner
    );
    await ISearchSECORewardingFacet.rewardMinerForHashes(
      owner.address,
      NUM_HASHES_MINED,
      0,
      REP_FRAC,
      dataHexString
    );

    // Get all relevant (updated) balances
    const newBalanceMe = await ERC20MonetaryToken.balanceOf(owner.address);
    const newBalanceTreasury = await ERC20MonetaryToken.balanceOf(daoAddress);
    const newBalanceMiningRewardPool =
      await IMiningRewardPoolFacet.getMiningRewardPool();

    /* -------------------- CALCULATE REWARD --------------------- */
    const miningRewardPoolBeforeReward = costWei // costWei is how much tokens were transferred to the treasury (from the monetization)
      .mul(TREASURY_RATIO)
      .div(1_000_000);
    const decimals18 = BigNumber.from(10).pow(18);
    const coinFrac = Math.round(
      (NUM_HASHES_MINED * (1_000_000 - REP_FRAC)) / 1_000_000 / HASH_DEVALUATION_FACTOR
    );
    const decimals18PowHashes = decimals18.pow(coinFrac);
    const reversePayoutRatio = decimals18
      .sub(decimals18.mul(MINING_REWARD_POOL_PAYOUT_RATIO_18).div(DECIMALS_18))
      .pow(coinFrac);
    const payoutRatio = decimals18PowHashes.sub(reversePayoutRatio);
    const payout = payoutRatio
      .mul(miningRewardPoolBeforeReward)
      .div(decimals18PowHashes);
    const expectedReward = payout;

    expect(newBalanceMe).to.be.equal(
      ether.mul(INITIAL_MINT_AMOUNT).sub(costWei).add(expectedReward)
    );
    expect(newBalanceTreasury).to.be.equal(costWei.sub(expectedReward));
    expect(newBalanceMiningRewardPool).to.be.equal(
      miningRewardPoolBeforeReward.sub(expectedReward)
    );
  });
});

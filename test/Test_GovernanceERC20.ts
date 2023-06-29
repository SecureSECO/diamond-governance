/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  *
  * This source code is licensed under the MIT license found in the
  * LICENSE file in the root directory of this source tree.
  */

/** 
 * Simple test to check if the totalVotingPower function works correctly.
 * Test will feature a DAO with 3 members, each with a different voting power.
 * The totalVotingPower should be the sum of the voting powers of the members that were verified at the time.
 */
 
// Framework
import { ethers } from "hardhat";

// Tests
import { expect } from "chai";
import { loadFixture, mine } from "@nomicfoundation/hardhat-network-helpers";

// Utils
import { getDeployedDiamondGovernance } from "../utils/deployedContracts";
import { createTestingDao, deployTestNetwork } from "./utils/testDeployer";
import { DiamondCut } from "../utils/diamondGovernanceHelper";
import { days, hours, now } from "../utils/timeUnits";
import { DECIMALS_18 } from "../utils/decimals18Helper";
import { DiamondGovernanceClient } from "../sdk";
import { ether } from "../utils/etherUnits";
import { createSignature } from "../utils/signatureHelper";

// Types

// Other

async function getClient() {
  await loadFixture(deployTestNetwork);
  const [owner] = await ethers.getSigners();
  const diamondGovernance = await getDeployedDiamondGovernance(owner);
  const GovernanceERC20FacetSettings = {
      _ERC20VotesFacetInitParams: {
          _ERC20PermitFacetInitParams: {
              _ERC20FacetInitParams: {
                  name: "Token",
                  symbol: "TOK",
              }
          }
      }
  };
  const ERC20TieredTimeClaimableFacetSettings = {
    tiers: [3, 10, 9999], //uint256[]
    rewards: [ether.mul(1), ether.mul(3), ether.mul(3)], //uint256[]
    _ERC20TimeClaimableFacetInitParams: {
      timeTillReward: 1 * days / 2, //uint256
      maxTimeRewarded: 10 * days / 2, //uint256
    },
  };
  const RewardMultiplierSettings = {
    name: "inflation",
    startTimestamp: 0,
    initialAmount: DECIMALS_18,
    slope: 0,
  };
  const VerificationSettings = {
    verificationContractAddress: diamondGovernance.SignVerification.address, //address
    providers: ["github", "proofofhumanity", "whitelist"], //string[]
    rewards: [3, 10, 9999], //uint256[]
  };
  const cut : DiamondCut[] = [
      await DiamondCut.All(diamondGovernance.GovernanceERC20Facet, [GovernanceERC20FacetSettings]),
      await DiamondCut.All(diamondGovernance.ERC20TieredTimeClaimableFacet, [ERC20TieredTimeClaimableFacetSettings]),
      await DiamondCut.All(diamondGovernance.RewardMultiplierFacet, [RewardMultiplierSettings]),
      await DiamondCut.All(diamondGovernance.VerificationFacet, [VerificationSettings]),
  ];
  return createTestingDao(cut);
}

describe("ERC20TimeClaimable", function () {
  it("should give 10 tokens on first claim", async function () {
    const client = await loadFixture(getClient);
    const IVerificationFacet = await client.pure.IVerificationFacet();
    const verificationContractAddress = await IVerificationFacet.getVerificationContractAddress();
    const standaloneVerificationContract = await ethers.getContractAt("SignVerification", verificationContractAddress);

    await mine(10 * days / 2);

    const [owner, alice, bob] = await ethers.getSigners();

    /// Verify owner and alice
    // Manually verify owner with github
    const timestamp = (await ethers.provider.getBlock(await ethers.provider.getBlockNumber())).timestamp;
    const userHash =
      "090d4910f4b4038000f6ea86644d55cb5261a1dc1f006d928dcc049b157daff8";
    const dataHexString = await createSignature(timestamp, owner.address, userHash, owner);
    await standaloneVerificationContract.verifyAddress(owner.address, userHash, timestamp, "github", dataHexString);

    // Manually verify alice with github
    const userHash2 =
      "randomUserHash2";
    const dataHexString2 = await createSignature(timestamp, alice.address, userHash2, owner);
    await standaloneVerificationContract.verifyAddress(alice.address, userHash2, timestamp, "github", dataHexString2);

    /// Claim time for owner and alice
    const aliceClient = new DiamondGovernanceClient(client.pure.pluginAddress, alice);

    await (await client.pure.IERC20TimeClaimableFacet()).claimTime();
    await (await aliceClient.pure.IERC20TimeClaimableFacet()).claimTime();

    /// Move time forward x blocks
    const originalBlockNumber = await ethers.provider.getBlockNumber();
    await mine(1 * hours); // two hours

    /// Verify bob
    // Timestamp is out of sync with the blockchain, so keep that in mind
    const timestamp2 = (await ethers.provider.getBlock(await ethers.provider.getBlockNumber())).timestamp;
    const userHash3 =
      "randomUserHash3";
    const dataHexString3 = await createSignature(timestamp2, bob.address, userHash3, owner);
    await standaloneVerificationContract.verifyAddress(bob.address, userHash3, timestamp2, "github", dataHexString3);

    // Claim time for bob
    const bobClient = new DiamondGovernanceClient(client.pure.pluginAddress, bob);
    await (await bobClient.pure.IERC20TimeClaimableFacet()).claimTime();

    /// Get total voting power of DAO before timeskip
    const IGovernanceStructure = await client.pure.IGovernanceStructure();

    const repInterface = await client.pure.IERC20();

    expect(await repInterface.balanceOf(owner.address)).to.equal(ether.mul(10));
    expect(await IGovernanceStructure.walletVotingPower(owner.address, originalBlockNumber)).to.equal(ether.mul(10));

    expect(await repInterface.balanceOf(alice.address)).to.equal(ether.mul(10));
    expect(await IGovernanceStructure.walletVotingPower(alice.address, originalBlockNumber)).to.equal(ether.mul(10));

    expect(await repInterface.balanceOf(bob.address)).to.equal(ether.mul(10));
    expect(await IGovernanceStructure.walletVotingPower(bob.address, originalBlockNumber)).to.equal(ether.mul(0));

  });
});
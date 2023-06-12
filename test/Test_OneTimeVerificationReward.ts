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
import { ether } from "../utils/etherUnits";

// Types

// Other

async function getClient() {
  await loadFixture(deployTestNetwork);
  const [owner] = await ethers.getSigners();
  const diamondGovernance = await getDeployedDiamondGovernance(owner);
  
  const ERC20OneTimeVerificationRewardFacetSettings = {
    providers: ["github", "proofofhumanity"], //string[]
    repRewards: [ether.mul(30), ether.mul(100)], //uint256[]
    coinRewards: [ether.mul(1), ether.mul(100)], //uint256[]
  };
  const MonetaryTokenFacetSettings = {
    monetaryTokenContractAddress: diamondGovernance.ERC20MonetaryToken.address,
  };
  const cut: DiamondCut[] = [
    await DiamondCut.All(diamondGovernance.VerificationRewardPoolFacet),
    await DiamondCut.All(diamondGovernance.ERC20OneTimeVerificationRewardFacet, [ERC20OneTimeVerificationRewardFacetSettings]),
    // await DiamondCut.All(diamondGovernance.ExecuteAnythingFacet),
    await DiamondCut.All(diamondGovernance.MonetaryTokenFacet, [MonetaryTokenFacetSettings]),
  ];
  return createTestingDao(cut);
}

describe.only("ERC20OneTimeVerificationReward", async function () {
  it("something", async function () {
    const client = await loadFixture(getClient);
    const IVerificationRewardPoolFacet = await client.pure.IVerificationRewardPoolFacet();

    await IVerificationRewardPoolFacet.increaseVerificationRewardPool(ether.mul(1e6));
  });
});
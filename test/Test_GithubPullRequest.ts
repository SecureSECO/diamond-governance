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

// Types

// Other

async function getClient() {
  await loadFixture(deployTestNetwork);
  const [owner] = await ethers.getSigners();
  const diamondGovernance = await getDeployedDiamondGovernance(owner);
  const cut : DiamondCut[] = [
      await DiamondCut.All(diamondGovernance.GithubPullRequestFacet),
  ];
  return createTestingDao(cut);
  }

describe("GithubPullRequest", () => {
  it("should emit the MergePullRequest event on calling merge", async () => {
    const client = await loadFixture(getClient);
    const IGithubPullRequestFacet = await client.pure.IGithubPullRequestFacet();
    expect(await IGithubPullRequestFacet.merge("owner", "repo", "0"))
        .to.emit(IGithubPullRequestFacet, "MergePullRequest")
        .withArgs("owner", "repo", "0");
  });  
});
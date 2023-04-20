/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  *
  * This source code is licensed under the MIT license found in the
  * LICENSE file in the root directory of this source tree.
  */

// Framework

// Tests
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";

// Utils

// Types

// Other
import { deployBaseAragonDAO } from "../deployments/deploy_BaseAragonDAO";
import { addFacetToDiamond } from "../deployments/deploy_DGSelection";
import { ethers } from "hardhat";

async function deployDiamondWithTest1Facet() {
    const { DiamondGovernance, diamondGovernanceContracts } = await loadFixture(deployBaseAragonDAO);
    return { DiamondGovernance, diamondGovernanceContracts };
}

describe("Github Pull Requests", () => {

  let GithubPullRequestFacetContract: any;
  let diamondData: any;

  beforeEach(async () => {
    const { DiamondGovernance, diamondGovernanceContracts } = await loadFixture(deployDiamondWithTest1Facet);
    diamondData = { DiamondGovernance, diamondGovernanceContracts };
    await addFacetToDiamond(diamondGovernanceContracts, DiamondGovernance.address, "GithubPullRequestFacet");

    GithubPullRequestFacetContract = await ethers.getContractAt("GithubPullRequestFacet", DiamondGovernance.address);
  });


  it("try call function to emit event as an outsider", async () => {
    await expect(GithubPullRequestFacetContract.mergePullRequest("owner", "repo", "0")).to.be.reverted;
  });

  it("call function to emit event as the dao", async () => {
    await addFacetToDiamond(
        diamondData.diamondGovernanceContracts, 
        diamondData.DiamondGovernance.address, 
        "GithubPullRequestMockFacet"
    );
    const GithubPullRequestMockFacetContract = await ethers.getContractAt("GithubPullRequestMockFacet", diamondData.DiamondGovernance.address);
    await expect(GithubPullRequestMockFacetContract._mergePullRequest("owner", "repo", "0"))
        .to.emit(GithubPullRequestFacetContract, "MergePullRequest")
        .withArgs("owner", "repo", "0");
  });  
});
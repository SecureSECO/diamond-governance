/**
 * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
 * © Copyright Utrecht University (Department of Information and Computing Sciences)
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

// Framework
import { deployBaseAragonDAO } from "../deployments/deploy_BaseAragonDAO";
import {
  DiamondDeployedContractsBase,
  addFacetToDiamondWithInit,
} from "../deployments/deploy_DGSelection";

// Tests
import { expect } from "chai";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { ethers } from "hardhat";

// Utils

// Types

// Other

describe("SearchSECORewarding", function () {
  it("try deploy/cut rewarding facet", async () => {
    const { DiamondGovernance, diamondGovernanceContracts } = await loadFixture(
      deployBaseAragonDAO
    );

    // Contract names
    const contractNames = {
      facetContractName: "SearchSECORewardingFacet",
      facetInitContractName: "SearchSECORewardingFacetInit",
      diamondInitName: "DISearchSECORewarding",
    };

    // Deploy facet contract
    const rewardingSettings = {
      users: [],
      hashCounts: [],
    };

    await addFacetToDiamondWithInit(
      diamondGovernanceContracts,
      DiamondGovernance.address,
      contractNames,
      rewardingSettings
    );

    const SearchSECORewardingFacet = await ethers.getContractAt(
      "SearchSECORewardingFacet",
      DiamondGovernance.address
    );

    const hashCount = await SearchSECORewardingFacet.getHashCount(
      ethers.constants.AddressZero
    );

    expect(hashCount).to.equal(0);
  });
});

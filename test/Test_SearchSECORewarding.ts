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
  addFacetToDiamond,
  addFacetToDiamondWithInit,
} from "../deployments/deploy_DGSelection";

// Tests
import { expect } from "chai";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { ethers } from "hardhat";

// Utils

// Types

// Other

async function deployDiamondWithTest1Facet() {
  const { DiamondGovernance, diamondGovernanceContracts } = await loadFixture(
    deployBaseAragonDAO
  );
  return { DiamondGovernance, diamondGovernanceContracts };
}

describe("SearchSECORewarding", function () {
  let SearchSECORewardingFacet: any;
  let diamondData: any;

  beforeEach(async () => {
    const { DiamondGovernance, diamondGovernanceContracts } = await loadFixture(
      deployDiamondWithTest1Facet
    );
    diamondData = { DiamondGovernance, diamondGovernanceContracts };
    await addFacetToDiamond(
      diamondGovernanceContracts,
      DiamondGovernance.address,
      "SearchSECORewardingFacet"
    );

    SearchSECORewardingFacet = await ethers.getContractAt(
      "SearchSECORewardingFacet",
      DiamondGovernance.address
    );
  });

  it("try deploy/cut rewarding facet", async () => {
    await addFacetToDiamond(
      diamondData.diamondGovernanceContracts,
      diamondData.DiamondGovernance.address,
      "SearchSECORewardingMockFacet"
    );

    const hashCount = await SearchSECORewardingFacet.getHashCount(
      ethers.constants.AddressZero
    );

    expect(hashCount).to.equal(0);
  });

  it("sets the hash reward", async () => {
    await addFacetToDiamond(
      diamondData.diamondGovernanceContracts,
      diamondData.DiamondGovernance.address,
      "SearchSECORewardingMockFacet"
    );

    const SearchSECORewardingMockFacetContract = await ethers.getContractAt(
      "SearchSECORewardingMockFacet",
      diamondData.DiamondGovernance.address
    );

    await SearchSECORewardingMockFacetContract._setHashReward(12345);

    const hashReward = await SearchSECORewardingFacet.getHashReward();

    expect(hashReward).to.equal(12345);
  });
});

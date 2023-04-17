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
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";

// Utils
import { 
    getSelectors,
    FacetCutAction,
    removeSelectors,
    findAddressPositionInFacets 
} from "../../utils/diamondHelper";

// Types

// Other
import { deployBaseAragonDAO } from "../../deployments/deploy_BaseAragonDAO";
import { addFacetToDiamond, addFacetToDiamondWithInit } from "../../deployments/deploy_DGSelection";
import { deployStandaloneVerificationContract } from "../../deployments/deploy_StandaloneVerificationContract";
import { searchSecoMonetization, verification } from "./addSingleFacet";

// async function deployDiamondWithTest1Facet() {
//     const { DAO, DiamondGovernance, diamondGovernanceContracts } = await loadFixture(deployBaseAragonDAO);
//     return { DAO, DiamondGovernance, diamondGovernanceContracts };
// }

describe("", () => {
  it("try deploy/cut verification facet", async () => {
    const { DiamondGovernance, diamondGovernanceContracts } = await loadFixture(deployBaseAragonDAO);

    await verification(diamondGovernanceContracts, DiamondGovernance.address);
  });

  it("try deploy/cut searchseco monetization", async () => {
    const { DiamondGovernance, diamondGovernanceContracts } = await loadFixture(deployBaseAragonDAO);

    await searchSecoMonetization(diamondGovernanceContracts, DiamondGovernance.address);
  });

  it("try deploy/cut verification then monetization", async () => {
    const { DiamondGovernance, diamondGovernanceContracts } = await loadFixture(deployBaseAragonDAO);

    await verification(diamondGovernanceContracts, DiamondGovernance.address);
    await searchSecoMonetization(diamondGovernanceContracts, DiamondGovernance.address);
  });
});
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  *
  * This source code is licensed under the MIT license found in the
  * LICENSE file in the root directory of this source tree.
  */

// Framework

// Tests
import { expect } from "chai";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";

// Utils
import { createTestingDao } from "./utils/testDeployer";
import { GetTypedContractAt } from "../utils/contractHelper";

// Types
import { DAO } from "../typechain-types";

// Other

async function getClient() {
  return createTestingDao([]);
}

describe("DAO", function () {
  it("should have the correct testing uri", async function () {
    const client = await loadFixture(getClient);
    const IDAOReferenceFacet = await client.pure.IDAOReferenceFacet();
    const DAO = await GetTypedContractAt<DAO>("DAO", await IDAOReferenceFacet.dao(), client.pure.signer);
    expect(await DAO.daoURI()).to.be.equal("https://plopmenz.com");
  });
});
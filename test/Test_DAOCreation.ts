// Framework
import { ethers } from "hardhat";

// Tests
import { expect } from "chai";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";

// Utils

// Types

// Other
import { deployAragonDAO } from "../deployments/deploy_AragonDAO";

describe("DAO", function () {
  it("should deploy", async function () {
    const { DAO } = await loadFixture(deployAragonDAO);
    expect(await DAO.daoURI()).to.be.equal("https://plopmenz.com");
  });
});
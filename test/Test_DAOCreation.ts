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

// Types

// Other
import { deployAragonDAO } from "../deployments/deploy_AragonDAO";

describe("DAO", function () {
  it("should deploy", async function () {
    const { DAO } = await loadFixture(deployAragonDAO);
    expect(await DAO.daoURI()).to.be.equal("https://plopmenz.com");
  });
});
// Framework
import { ethers } from "hardhat";

// Tests
import { expect } from "chai";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";

// Utils

// Types

// Other
import { deployAragonDAO } from "../deployments/deploy_AragonDAO";

describe("ERC20Claimable", function () {
  it("should give 10 tokens on first claim", async function () {
    const { DiamondGovernance } = await loadFixture(deployAragonDAO);
    const ERC20ClaimableFacet = await ethers.getContractAt("ERC20ClaimableFacet", DiamondGovernance.address);
    const ERC20Facet = await ethers.getContractAt("ERC20Facet", DiamondGovernance.address);
    const [owner] = await ethers.getSigners();

    const balanceBefore = await ERC20Facet.balanceOf(owner.address);
    await ERC20ClaimableFacet.claim();
    const balanceAfter = await ERC20Facet.balanceOf(owner.address);

    expect(balanceAfter).to.be.equal(balanceBefore.add(10));
  });

  it("should give 0 tokens on claim after just having claimed", async function () {
    const { DiamondGovernance } = await loadFixture(deployAragonDAO);
    const ERC20ClaimableFacet = await ethers.getContractAt("ERC20ClaimableFacet", DiamondGovernance.address);
    const ERC20Facet = await ethers.getContractAt("ERC20Facet", DiamondGovernance.address);
    const [owner] = await ethers.getSigners();

    await ERC20ClaimableFacet.claim();
    const balanceBefore = await ERC20Facet.balanceOf(owner.address);
    await ERC20ClaimableFacet.claim();
    const balanceAfter = await ERC20Facet.balanceOf(owner.address);

    expect(balanceAfter).to.be.equal(balanceBefore);
  });
});
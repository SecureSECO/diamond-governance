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
import { createProposal, voteOnProposal, VoteOption } from "./Test_PartialVoting"

describe("PartialBurnVoting", function () {
  // Simple
  it("should burn the used voting power on yes", async function () {
    const { DiamondGovernance, proposalId } = await loadFixture(createProposal);
    const PartialBurnVotingProposalFacet = await ethers.getContractAt("PartialBurnVotingProposalFacet", DiamondGovernance.address);
    const PartialVotingFacet = await ethers.getContractAt("PartialVotingFacet", DiamondGovernance.address);
    const ERC20Facet = await ethers.getContractAt("ERC20Facet", DiamondGovernance.address);
    const [owner] = await ethers.getSigners();
    const amount = 2;

    const balanceBefore = await ERC20Facet.balanceOf(owner.address);
    await voteOnProposal(PartialVotingFacet, PartialBurnVotingProposalFacet, proposalId, { option: VoteOption.Yes, amount: amount });
    const balanceAfter = await ERC20Facet.balanceOf(owner.address);

    expect(balanceAfter).to.be.equal(balanceBefore.sub(amount));
  });

  it("should burn the used voting power on no", async function () {
    const { DiamondGovernance, proposalId } = await loadFixture(createProposal);
    const PartialBurnVotingProposalFacet = await ethers.getContractAt("PartialBurnVotingProposalFacet", DiamondGovernance.address);
    const PartialVotingFacet = await ethers.getContractAt("PartialVotingFacet", DiamondGovernance.address);
    const ERC20Facet = await ethers.getContractAt("ERC20Facet", DiamondGovernance.address);
    const [owner] = await ethers.getSigners();
    const amount = 1;

    const balanceBefore = await ERC20Facet.balanceOf(owner.address);
    await voteOnProposal(PartialVotingFacet, PartialBurnVotingProposalFacet, proposalId, { option: VoteOption.No, amount: amount });
    const balanceAfter = await ERC20Facet.balanceOf(owner.address);

    expect(balanceAfter).to.be.equal(balanceBefore.sub(amount));
  });

  it("should burn no voting power on abstain", async function () {
    const { DiamondGovernance, proposalId } = await loadFixture(createProposal);
    const PartialBurnVotingProposalFacet = await ethers.getContractAt("PartialBurnVotingProposalFacet", DiamondGovernance.address);
    const PartialVotingFacet = await ethers.getContractAt("PartialVotingFacet", DiamondGovernance.address);
    const ERC20Facet = await ethers.getContractAt("ERC20Facet", DiamondGovernance.address);
    const [owner] = await ethers.getSigners();
    const amount = 4;

    const balanceBefore = await ERC20Facet.balanceOf(owner.address);
    await voteOnProposal(PartialVotingFacet, PartialBurnVotingProposalFacet, proposalId, { option: VoteOption.Abstain, amount: amount });
    const balanceAfter = await ERC20Facet.balanceOf(owner.address);

    expect(balanceAfter).to.be.equal(balanceBefore);
  });

  it("should have 9 voting power after proposal creation", async function () { 
    const { DiamondGovernance } = await loadFixture(createProposal);
    const ERC20Facet = await ethers.getContractAt("ERC20Facet", DiamondGovernance.address);
    const [owner] = await ethers.getSigners();

    const balance = await ERC20Facet.balanceOf(owner.address);

    expect(balance).to.be.equal(9);
  });
});
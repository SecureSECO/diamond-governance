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
import { loadFixture, time } from "@nomicfoundation/hardhat-network-helpers";

// Utils
import { toBytes, getEvents } from "../utils/utils";
import { deployAragonDAOAndVerifyFixture } from "../utils/verificationHelper";
import { now, minutes, days } from "../utils/timeUnits";

// Types
import { DiamondGovernance, IPartialVotingFacet, PartialVotingFacet, PartialVotingProposalFacet } from "../typechain-types";

// Other

enum VoteOption { Abstain, Yes, No }

async function getVotingPower(DiamondGovernance : DiamondGovernance) {
  const ERC20TimeClaimableFacet = await ethers.getContractAt("ERC20TimeClaimableFacet", DiamondGovernance.address);
  await ERC20TimeClaimableFacet.claimTime();
}

async function createProposal() {
  const { DiamondGovernance } = await loadFixture(deployAragonDAOAndVerifyFixture);
  await getVotingPower(DiamondGovernance);
  const PartialVotingProposalFacet = await ethers.getContractAt("PartialVotingProposalFacet", DiamondGovernance.address);

  const start = now() + 20 * minutes;
  const proposalData = {
      _metadata: toBytes("Metadata"), //bytes
      _actions: [], //IDAO.Action[]
      _allowFailureMap: 0, //uint256
      _startDate: start, //uint64
      _endDate: start + 2 * days, //uint64
      _allowEarlyExecution: true //bool
  }
  const tx = await PartialVotingProposalFacet.createProposal(proposalData._metadata, proposalData._actions, proposalData._allowFailureMap, 
    proposalData._startDate, proposalData._endDate, proposalData._allowEarlyExecution);
  const receipt = await tx.wait();
  const proposalCreationEvents = getEvents(PartialVotingProposalFacet, "ProposalCreated", receipt).map((log : any) => log.name);
  expect(proposalCreationEvents).to.be.lengthOf(1);

  await time.increaseTo(start + 1);
  const proposalId = PartialVotingProposalFacet.interface.parseLog(receipt.logs[0]).args.proposalId;
  const proposal = await PartialVotingProposalFacet.getProposal(proposalId);
  expect(proposal.tally.yes).to.be.equal(0);
  expect(proposal.tally.no).to.be.equal(0);
  expect(proposal.tally.abstain).to.be.equal(0);

  return { DiamondGovernance, proposalId, proposal };
}

async function voteOnProposal(PartialVotingFacet : PartialVotingFacet, PartialVotingProposalFacet : PartialVotingProposalFacet, proposalId : any, voteData : IPartialVotingFacet.PartialVoteStruct) {
  const tx = await PartialVotingFacet.vote(proposalId, voteData);
  const receipt = await tx.wait();

  const voteCastEvents = getEvents(PartialVotingFacet, "VoteCast", receipt).map((log : any) => log.name);
  expect(voteCastEvents).to.be.lengthOf(1);
  
  const proposalAfterVote = await PartialVotingProposalFacet.getProposal(proposalId);
  return proposalAfterVote;
}

describe("PartialVoting", function () {
  // Allowed simple
  it("should increase yes with the right amount when voting yes on proposal", async function () {
    const { DiamondGovernance, proposalId, proposal } = await loadFixture(createProposal);
    const PartialBurnVotingProposalFacet = await ethers.getContractAt("PartialBurnVotingProposalFacet", DiamondGovernance.address);
    const PartialVotingFacet = await ethers.getContractAt("PartialVotingFacet", DiamondGovernance.address);
    const amount = 2;

    const proposalAfterVote = await voteOnProposal(PartialVotingFacet, PartialBurnVotingProposalFacet, proposalId, { option: VoteOption.Yes, amount: amount });

    expect(proposalAfterVote.tally.abstain).to.be.equal(proposal.tally.abstain);
    expect(proposalAfterVote.tally.yes).to.be.equal(proposal.tally.yes.add(amount));
    expect(proposalAfterVote.tally.no).to.be.equal(proposal.tally.no);
  });

  it("should increase no with the right amount when voting no on proposal", async function () {
    const { DiamondGovernance, proposalId, proposal } = await loadFixture(createProposal);
    const PartialBurnVotingProposalFacet = await ethers.getContractAt("PartialBurnVotingProposalFacet", DiamondGovernance.address);
    const PartialVotingFacet = await ethers.getContractAt("PartialVotingFacet", DiamondGovernance.address);
    const amount = 1;

    const proposalAfterVote = await voteOnProposal(PartialVotingFacet, PartialBurnVotingProposalFacet, proposalId, { option: VoteOption.No, amount: amount });

    expect(proposalAfterVote.tally.abstain).to.be.equal(proposal.tally.abstain);
    expect(proposalAfterVote.tally.yes).to.be.equal(proposal.tally.yes);
    expect(proposalAfterVote.tally.no).to.be.equal(proposal.tally.no.add(amount));
  });

  it("should increase abstain with the right amount when voting abstain on proposal", async function () {
    const { DiamondGovernance, proposalId, proposal } = await loadFixture(createProposal);
    const PartialBurnVotingProposalFacet = await ethers.getContractAt("PartialBurnVotingProposalFacet", DiamondGovernance.address);
    const PartialVotingFacet = await ethers.getContractAt("PartialVotingFacet", DiamondGovernance.address);
    const amount = 4;

    const proposalAfterVote = await voteOnProposal(PartialVotingFacet, PartialBurnVotingProposalFacet, proposalId, { option: VoteOption.Abstain, amount: amount });

    expect(proposalAfterVote.tally.abstain).to.be.equal(proposal.tally.abstain.add(amount));
    expect(proposalAfterVote.tally.yes).to.be.equal(proposal.tally.yes);
    expect(proposalAfterVote.tally.no).to.be.equal(proposal.tally.no);
  });

  //Allowed advanced
  it("should increase yes with the right amount when voting yes multiple times on proposal", async function () {
    const { DiamondGovernance, proposalId, proposal } = await loadFixture(createProposal);
    const PartialBurnVotingProposalFacet = await ethers.getContractAt("PartialBurnVotingProposalFacet", DiamondGovernance.address);
    const PartialVotingFacet = await ethers.getContractAt("PartialVotingFacet", DiamondGovernance.address);
    const amounts = [1, 2];

    let proposalAfterVote = proposal;
    let total = 0;
    for (let i = 0; i < amounts.length; i++) {
      proposalAfterVote = await voteOnProposal(PartialVotingFacet, PartialBurnVotingProposalFacet, proposalId, { option: VoteOption.Yes, amount: amounts[i] });
      total = total + amounts[i];
    }

    expect(proposalAfterVote.tally.abstain).to.be.equal(proposal.tally.abstain);
    expect(proposalAfterVote.tally.yes).to.be.equal(proposal.tally.yes.add(total));
    expect(proposalAfterVote.tally.no).to.be.equal(proposal.tally.no);
  });

  it("should increase yes and no with the right amount when voting yes and no on proposal", async function () {
    const { DiamondGovernance, proposalId, proposal } = await loadFixture(createProposal);
    const PartialBurnVotingProposalFacet = await ethers.getContractAt("PartialBurnVotingProposalFacet", DiamondGovernance.address);
    const PartialVotingFacet = await ethers.getContractAt("PartialVotingFacet", DiamondGovernance.address);
    const amountYes = 4;
    const amountNo = 4;

    await voteOnProposal(PartialVotingFacet, PartialBurnVotingProposalFacet, proposalId, { option: VoteOption.Yes, amount: amountYes });
    const proposalAfterVote = await voteOnProposal(PartialVotingFacet, PartialBurnVotingProposalFacet, proposalId, { option: VoteOption.No, amount: amountNo });

    expect(proposalAfterVote.tally.abstain).to.be.equal(proposal.tally.abstain);
    expect(proposalAfterVote.tally.yes).to.be.equal(proposal.tally.yes.add(amountYes));
    expect(proposalAfterVote.tally.no).to.be.equal(proposal.tally.no.add(amountNo));
  });
  
  // Not allowed
  it("should not allow to vote with amount 0", async function () { 
    const { DiamondGovernance, proposalId } = await loadFixture(createProposal);
    const PartialVotingFacet = await ethers.getContractAt("PartialVotingFacet", DiamondGovernance.address);

    const voteTx = PartialVotingFacet.vote(proposalId, { option: VoteOption.Yes, amount: 0 });

    expect(voteTx).to.be.revertedWithCustomError(PartialVotingFacet, "VoteCastForbidden");
  });

  it("should not allow to vote with amount higher than voting power", async function () { 
    const { DiamondGovernance, proposalId, proposal } = await loadFixture(createProposal);
    const PartialVotingFacet = await ethers.getContractAt("PartialVotingFacet", DiamondGovernance.address);
    const IGovernanceStructure = await ethers.getContractAt("IGovernanceStructure", DiamondGovernance.address);
    const [owner] = await ethers.getSigners();

    const votingPower = await IGovernanceStructure.walletVotingPower(owner.address, proposal.parameters.snapshotBlock);
    const voteTx = PartialVotingFacet.vote(proposalId, { option: VoteOption.Yes, amount: votingPower.add(1)});

    expect(voteTx).to.be.revertedWithCustomError(PartialVotingFacet, "VoteCastForbidden");
  });
});

export { createProposal, voteOnProposal, VoteOption }
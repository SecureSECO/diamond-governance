// Framework
import { ethers } from "hardhat";

// Tests
import { expect } from "chai";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";

// Utils
import { toBytes, getEvents } from "../utils/utils";

// Types
import { IPartialVoting, PartialTokenBurnVoting } from "../typechain-types";

// Other
import { deployAragonDAO } from "../deployments/deploy_AragonDAO";

enum VoteOption { Abstain, Yes, No }

async function createProposal() {
  const { PartialTokenBurnVoting } = await loadFixture(deployAragonDAO);

  const Action = {
    to: "", //address
    value: "", //uint256
    data: "" //bytes
  };

  const PartialVote = {
      option: VoteOption.Yes, //Abstain, Yes, No
      amount: 1 //uint
  };

  const proposalData = {
      _metadata: toBytes("Metadata"), //bytes
      _actions: [], //IDAO.Action[]
      _allowFailureMap: 0, //uint256
      _startDate: 0, //uint64
      _endDate: 0, //uint64
      _voteData: PartialVote, //PartialVote
      _tryEarlyExecution: true //bool
  }
  const tx = await PartialTokenBurnVoting.createProposal(proposalData._metadata, proposalData._actions, proposalData._allowFailureMap, proposalData._startDate, 
      proposalData._endDate, proposalData._voteData, proposalData._tryEarlyExecution);
  const receipt = await tx.wait();
  const proposalCreationEvents = getEvents(PartialTokenBurnVoting, "ProposalCreated", receipt).map((log : any) => log.name);
  expect(proposalCreationEvents).to.be.lengthOf(1);

  const proposalId = PartialTokenBurnVoting.interface.parseLog(receipt.logs[0]).args.proposalId;
  const proposal = await PartialTokenBurnVoting.getProposal(proposalId);
  expect(proposal.tally.yes).to.be.equal(1);
  expect(proposal.tally.no).to.be.equal(0);
  expect(proposal.tally.abstain).to.be.equal(0);

  return { proposalId, proposal };
}

async function voteOnProposal(PartialTokenBurnVoting : PartialTokenBurnVoting, proposalId : any, voteData : IPartialVoting.PartialVoteStruct) {
  const [ owner ] = await ethers.getSigners();

  const NonTransferableGovernanceERC20Contract = await ethers.getContractFactory("NonTransferableGovernanceERC20");
  const NonTransferableGovernanceERC20 = await NonTransferableGovernanceERC20Contract.attach(await PartialTokenBurnVoting.getVotingToken());
  const tokensBeforeVote = await NonTransferableGovernanceERC20.balanceOf(owner.address);

  const tx = await PartialTokenBurnVoting.vote(proposalId, voteData, false);
  const receipt = await tx.wait();

  const voteCastEvents = getEvents(PartialTokenBurnVoting, "VoteCast", receipt).map((log : any) => log.name);
  expect(voteCastEvents).to.be.lengthOf(1);

  const proposalAfterVote = await PartialTokenBurnVoting.getProposal(proposalId);
  const tokensAfterVote = await NonTransferableGovernanceERC20.balanceOf(owner.address);
  if (proposalAfterVote.parameters.votingMode.burnTokens) {
    expect(tokensAfterVote).to.be.equal(tokensBeforeVote.sub(await voteData.amount));
  }
  else {
    expect(tokensAfterVote).to.be.equal(tokensBeforeVote);
  }

  return proposalAfterVote;
}

describe("PartialTokenBurnVoting contract", function () {
  // Allowed simple
  it("Vote yes on proposal", async function () {
    const { PartialTokenBurnVoting } = await loadFixture(deployAragonDAO);
    const { proposalId, proposal } = await loadFixture(createProposal);

    const proposalAfterVote = await voteOnProposal(PartialTokenBurnVoting, proposalId, { option: VoteOption.Yes, amount: 2 });

    expect(proposalAfterVote.tally.abstain).to.be.equal(proposal.tally.abstain);
    expect(proposalAfterVote.tally.yes).to.be.equal(proposal.tally.yes.add(2));
    expect(proposalAfterVote.tally.no).to.be.equal(proposal.tally.no);
  });

  it("Vote no on proposal", async function () {
    const { PartialTokenBurnVoting } = await loadFixture(deployAragonDAO);
    const { proposalId, proposal } = await loadFixture(createProposal);

    const proposalAfterVote = await voteOnProposal(PartialTokenBurnVoting, proposalId, { option: VoteOption.No, amount: 1 });

    expect(proposalAfterVote.tally.abstain).to.be.equal(proposal.tally.abstain);
    expect(proposalAfterVote.tally.yes).to.be.equal(proposal.tally.yes);
    expect(proposalAfterVote.tally.no).to.be.equal(proposal.tally.no.add(1));
  });

  it("Vote abstain on proposal", async function () {
    const { PartialTokenBurnVoting } = await loadFixture(deployAragonDAO);
    const { proposalId, proposal } = await loadFixture(createProposal);

    const proposalAfterVote = await voteOnProposal(PartialTokenBurnVoting, proposalId, { option: VoteOption.Abstain, amount: 4 });

    expect(proposalAfterVote.tally.abstain).to.be.equal(proposal.tally.abstain.add(4));
    expect(proposalAfterVote.tally.yes).to.be.equal(proposal.tally.yes);
    expect(proposalAfterVote.tally.no).to.be.equal(proposal.tally.no);
  });

  //Allowed advanced
  it("Vote yes twice on proposal", async function () {
    const { PartialTokenBurnVoting } = await loadFixture(deployAragonDAO);
    const { proposalId, proposal } = await loadFixture(createProposal);

    await voteOnProposal(PartialTokenBurnVoting, proposalId, { option: VoteOption.Yes, amount: 1 });
    const proposalAfterVote = await voteOnProposal(PartialTokenBurnVoting, proposalId, { option: VoteOption.Yes, amount: 2 });

    expect(proposalAfterVote.tally.abstain).to.be.equal(proposal.tally.abstain);
    expect(proposalAfterVote.tally.yes).to.be.equal(proposal.tally.yes.add(3));
    expect(proposalAfterVote.tally.no).to.be.equal(proposal.tally.no);
  });

  it("Vote yes and no on proposal", async function () {
    const { PartialTokenBurnVoting } = await loadFixture(deployAragonDAO);
    const { proposalId, proposal } = await loadFixture(createProposal);

    await voteOnProposal(PartialTokenBurnVoting, proposalId, { option: VoteOption.Yes, amount: 4 });
    const proposalAfterVote = await voteOnProposal(PartialTokenBurnVoting, proposalId, { option: VoteOption.No, amount: 3 });

    expect(proposalAfterVote.tally.abstain).to.be.equal(proposal.tally.abstain);
    expect(proposalAfterVote.tally.yes).to.be.equal(proposal.tally.yes.add(4));
    expect(proposalAfterVote.tally.no).to.be.equal(proposal.tally.no.add(3));
  });
  
  // Not allowed
  it("Vote with 0 amount", async function () { 
    const { PartialTokenBurnVoting } = await loadFixture(deployAragonDAO);
    const { proposalId } = await loadFixture(createProposal);

    const voteTx = PartialTokenBurnVoting.vote(proposalId, { option: 2, amount: 0 }, false);

    expect(voteTx).to.be.revertedWithCustomError(PartialTokenBurnVoting, "VoteCastForbidden");
  });
  
  it("Vote with more token than in wallet", async function () { 
    const { PartialTokenBurnVoting } = await loadFixture(deployAragonDAO);
    const { proposalId } = await loadFixture(createProposal);
    
    const voteTx = PartialTokenBurnVoting.vote(proposalId, { option: 2, amount: 11 }, false);

    expect(voteTx).to.be.revertedWithCustomError(PartialTokenBurnVoting, "VoteCastForbidden");
  });
});
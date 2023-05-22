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
import { now, days } from "../utils/timeUnits";
import { getDeployedDiamondGovernance } from "../utils/deployedContracts";
import { DiamondCut } from "../utils/diamondGovernanceHelper";
import { createTestingDao } from "./utils/testDeployer";
import { wei } from "../utils/etherUnits";
import { getEvents } from "../utils/utils";

// Types

// Other
import { DiamondGovernanceClient, ProposalMetadata, VoteOption } from "../sdk/index";

async function getClient() {
    const [owner] = await ethers.getSigners();
    const diamondGovernance = await getDeployedDiamondGovernance(owner);
    enum VotingMode {
        SingleVote,
        SinglePartialVote,
        MultiplePartialVote,
    }
    const PartialVotingProposalFacetSettings = {
        votingSettings: {
            votingMode: VotingMode.MultiplePartialVote,
            supportThreshold: 1,
            minParticipation: 1,
            maxSingleWalletPower: 10**6,
            minDuration: 1 * days,
            minProposerVotingPower: wei.mul(1),
        },
    };
    const GovernanceERC20FacetSettings = {
        _ERC20VotesFacetInitParams: {
            _ERC20PermitFacetInitParams: {
                _ERC20FacetInitParams: {
                    name: "Token",
                    symbol: "TOK",
                }
            }
        }
    };
    const cut : DiamondCut[] = [
        await DiamondCut.All(diamondGovernance.PartialVotingProposalFacet, [PartialVotingProposalFacetSettings]),
        await DiamondCut.All(diamondGovernance.PartialVotingFacet),
        await DiamondCut.All(diamondGovernance.GovernanceERC20Facet, [GovernanceERC20FacetSettings]),
        await DiamondCut.All(diamondGovernance.AlwaysMemberTier1Facet),
    ];
    return createTestingDao(cut);
  }


async function createProposal() {
    const client = await loadFixture(getClient);
    await getVotingPower(client);
    return createProposalWithClient(client);
}

export async function getVotingPower(client : DiamondGovernanceClient) {
    const [owner] = await ethers.getSigners();
    const IMintableGovernanceStructure = await client.pure.IMintableGovernanceStructure();
    await IMintableGovernanceStructure.mintVotingPower(owner.address, 0, 10);
}


export async function createProposalWithClient(client : DiamondGovernanceClient) {
  // Proposal parameters
  const startTime = 0; // 0 will get translated to block.timestamp
  const endTime = now() + 2 * days;

  const start = new Date();
  start.setTime(startTime * 1000);
  const end = new Date();
  end.setTime(endTime * 1000);

  const metadata : ProposalMetadata = {
    title: "Title",
    description: "Description",
    body: "Body",
    resources: []
  };

  // Create proposal
  const tx = await client.sugar.CreateProposal(metadata, [], start, end);
  const receipt = await tx.wait();

  // Retrieve proposal information
  const IProposal = await client.pure.IProposal();
  const proposalCreationEvent = getEvents(IProposal, "ProposalCreated", receipt);
  if (proposalCreationEvent.length < 1) {
    throw new Error("Proposal creation event not found");
  }
  const proposalId = proposalCreationEvent[0].args.proposalId;
  const proposal = await client.sugar.GetProposal(proposalId);

  return { client, proposal };
}

describe("PartialVoting", function () {
  // Allowed simple
  it("should increase yes with the right amount when voting yes on proposal", async function () {
    const { proposal} = await loadFixture(createProposal);
    const amount = wei.mul(2);

    const abstainBefore = wei.mul(0);
    const yesBefore = wei.mul(0);
    const noBefore = wei.mul(0);
    await proposal.Vote(VoteOption.Yes, amount);
    await proposal.Refresh();

    expect(abstainBefore).to.be.equal(proposal.data.tally.abstain);
    expect(yesBefore.add(amount)).to.be.equal(proposal.data.tally.yes);
    expect(noBefore).to.be.equal(proposal.data.tally.no);
  });

  it("should increase no with the right amount when voting no on proposal", async function () {
    const { proposal} = await loadFixture(createProposal);
    const amount = wei.mul(1);

    const abstainBefore = wei.mul(0);
    const yesBefore = wei.mul(0);
    const noBefore = wei.mul(0);
    await proposal.Vote(VoteOption.No, amount);
    await proposal.Refresh();

    expect(abstainBefore).to.be.equal(proposal.data.tally.abstain);
    expect(yesBefore).to.be.equal(proposal.data.tally.yes);
    expect(noBefore.add(amount)).to.be.equal(proposal.data.tally.no);
  });

  it("should increase abstain with the right amount when voting abstain on proposal", async function () {
    const { proposal} = await loadFixture(createProposal);
    const amount = wei.mul(4);

    const abstainBefore = wei.mul(0);
    const yesBefore = wei.mul(0);
    const noBefore = wei.mul(0);
    await proposal.Vote(VoteOption.Abstain, amount);
    await proposal.Refresh();

    expect(abstainBefore.add(amount)).to.be.equal(proposal.data.tally.abstain);
    expect(yesBefore).to.be.equal(proposal.data.tally.yes);
    expect(noBefore).to.be.equal(proposal.data.tally.no);
  });

  //Allowed advanced
  it("should increase yes with the right amount when voting yes multiple times on proposal", async function () {
    const { proposal} = await loadFixture(createProposal);
    const amounts = [ wei.mul(1),  wei.mul(2)];

    const abstainBefore = wei.mul(0);
    const yesBefore = wei.mul(0);
    const noBefore = wei.mul(0);
    let total = wei.mul(0);
    for (let i = 0; i < amounts.length; i++) {
      await proposal.Vote(VoteOption.Yes, amounts[i]);
      total = total.add(amounts[i]);
    }
    await proposal.Refresh();

    expect(abstainBefore).to.be.equal(proposal.data.tally.abstain);
    expect(yesBefore.add(total)).to.be.equal(proposal.data.tally.yes);
    expect(noBefore).to.be.equal(proposal.data.tally.no);
  });

  it("should increase yes and no with the right amount when voting yes and no on proposal", async function () {
    const { proposal} = await loadFixture(createProposal);
    const amountYes = wei.mul(1);
    const amountNo = wei.mul(2);

    const abstainBefore = wei.mul(0);
    const yesBefore = wei.mul(0);
    const noBefore = wei.mul(0);
    await proposal.Vote(VoteOption.Yes, amountYes);
    await proposal.Vote(VoteOption.No, amountNo);
    await proposal.Refresh();

    expect(abstainBefore).to.be.equal(proposal.data.tally.abstain);
    expect(yesBefore.add(amountYes)).to.be.equal(proposal.data.tally.yes);
    expect(noBefore.add(amountNo)).to.be.equal(proposal.data.tally.no);
  });
  
  // Not allowed
  it("should not allow to vote with amount 0", async function () {
    const { client, proposal} = await loadFixture(createProposal);
    const IPartialVotingFacet = await client.pure.IPartialVotingFacet();

    const voteTx = proposal.Vote(VoteOption.Yes, wei.mul(0));

    expect(voteTx).to.be.revertedWithCustomError(IPartialVotingFacet, "VoteCastForbidden");
  });

  it("should not allow to vote with amount higher than voting power", async function () { 
    const { client, proposal} = await loadFixture(createProposal);
    const IGovernanceStructure = await client.pure.IGovernanceStructure();
    const IPartialVotingFacet = await client.pure.IPartialVotingFacet();
    const [owner] = await ethers.getSigners();

    const votingPower = await IGovernanceStructure.walletVotingPower(owner.address, proposal.data.parameters.snapshotBlock);
    const voteTx = proposal.Vote(VoteOption.Yes, votingPower.add(1));

    expect(voteTx).to.be.revertedWithCustomError(IPartialVotingFacet, "VoteCastForbidden");
  });
});
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
import { wei } from "../utils/etherUnits";
import { now, days } from "../utils/timeUnits";

// Types

// Other
import { DiamondGovernanceClient, ProposalSorting, ProposalMetadata, Action, SortingOrder, VoteOption } from "../sdk/index";
import { getClient, getVotingPower } from "./Test_PartialVoting";
import { getExampleMetaData } from "./Test_PartialVotingProposal";

export async function createProposalWithClient(client : DiamondGovernanceClient, metadata : ProposalMetadata, actions : Action[]) {
  // Proposal parameters
  const startTime = 0; // 0 will get translated to block.timestamp
  const endTime = now() + 2 * days;

  const start = new Date();
  start.setTime(startTime * 1000);
  const end = new Date();
  end.setTime(endTime * 1000);

  // Create proposal
  await client.sugar.CreateProposal(metadata, actions, start, end);
}

describe("Proposal SDK sugar", function () {
  it("should return all proposals on get", async function () {
    const client = await loadFixture(getClient);
    await getVotingPower(client);
    let proposalCount = 5;
    await client.sugar.ClearProposalCache();

    // Create proposals
    for (let i = 0; i < proposalCount; i++) {
      await createProposalWithClient(client, getExampleMetaData(), []);
    }

    // Fetch all proposals
    const proposals = await client.sugar.GetProposals();

    // Fetch all proposals one by one
    const proposalsIndividual = [];
    for (let i = 0; i < proposalCount; i++) { 
      proposalsIndividual.push(await client.sugar.GetProposal(i));
    }

    expect(proposals).to.have.same.members(proposalsIndividual);
  });

  it("should sort the proposals on title ascendingly", async function () {
    const client = await loadFixture(getClient);
    await getVotingPower(client);
    const titles = ["Empty treasury", "Kick all members", "Delete DAO", "Remove governance plugin"];
    await client.sugar.ClearProposalCache();

    // Create proposals
    for (let i = 0; i < titles.length; i++) {
      let metadata = getExampleMetaData();
      metadata.title = titles[i];
      await createProposalWithClient(client, metadata, []);
    }

    const proposals = await client.sugar.GetProposals(undefined, ProposalSorting.Title, SortingOrder.Asc);
    const sortedTitles = [...titles].sort();
    const indexes = sortedTitles.map(sortedTitle => titles.findIndex(title => title == sortedTitle));

    expect(proposals.map(prop => prop.id)).to.eql(indexes);
  });

  it("should sort the proposals on title descendingly", async function () {
    const client = await loadFixture(getClient);
    await getVotingPower(client);
    const titles = ["Empty treasury", "Kick all members", "Delete DAO", "Remove governance plugin"];
    await client.sugar.ClearProposalCache();

    // Create proposals
    for (let i = 0; i < titles.length; i++) {
      let metadata = getExampleMetaData();
      metadata.title = titles[i];
      await createProposalWithClient(client, metadata, []);
    }

    const proposals = await client.sugar.GetProposals(undefined, ProposalSorting.Title, SortingOrder.Desc);
    const sortedTitles = [...titles].sort().reverse();
    const indexes = sortedTitles.map(sortedTitle => titles.findIndex(title => title == sortedTitle));

    expect(proposals.map(prop => prop.id)).to.eql(indexes);
  });

  it("should sort the proposals on total votes ascendingly", async function () {
    const client = await loadFixture(getClient);
    await getVotingPower(client);
    const votes = [7, 5, 6, 3, 2, 1, 4];
    await client.sugar.ClearProposalCache();

    // Create proposals
    for (let i = 0; i < votes.length; i++) {
      await createProposalWithClient(client, getExampleMetaData(), []);
      const proposal = await client.sugar.GetProposal(i);
      await proposal.Vote(VoteOption.Yes, wei.mul(votes[i]));
      await proposal.Refresh();
    }

    const proposals = await client.sugar.GetProposals(undefined, ProposalSorting.TotalVotes, SortingOrder.Asc);
    const sortedVotes = [...votes].sort();
    const indexes = sortedVotes.map(sortedVote => votes.findIndex(vote => vote == sortedVote));

    expect(proposals.map(prop => prop.id)).to.eql(indexes);
  });
  
  it("should use cache correctly", async function () {
    const client = await loadFixture(getClient);
    await getVotingPower(client);
    const votes = [7, 5, 6, 3];
    const titles = ["Empty treasury", "Kick all members", "Delete DAO", "Remove governance plugin"];
    await client.sugar.ClearProposalCache();

    // Create proposals
    for (let i = 0; i < votes.length; i++) {
      let metadata = getExampleMetaData();
      metadata.title = titles[i];
      await createProposalWithClient(client, metadata, []);
      const proposal = await client.sugar.GetProposal(i);
      await proposal.Vote(VoteOption.Yes, wei.mul(votes[i]));
      await proposal.Refresh();
    }
    const proposalSortedCreation = await client.sugar.GetProposals(undefined, ProposalSorting.Creation, SortingOrder.Asc);
    const sortedCreationIndexes = [0, 1, 2, 3];

    const proposalSortedVotes = await client.sugar.GetProposals(undefined, ProposalSorting.TotalVotes, SortingOrder.Asc);
    const sortedVotes = [...votes].sort();
    const sortedVotesIndexes = sortedVotes.map(sortedVote => votes.findIndex(vote => vote == sortedVote));

    const proposalSortedTitles = await client.sugar.GetProposals(undefined, ProposalSorting.Title, SortingOrder.Asc);
    const sortedTitles = [...titles].sort();
    const sortedTitlesIndexes = sortedTitles.map(sortedTitle => titles.findIndex(title => title == sortedTitle));

    expect(proposalSortedCreation.map(prop => prop.id)).to.eql(sortedCreationIndexes);
    expect(proposalSortedVotes.map(prop => prop.id)).to.eql(sortedVotesIndexes);
    expect(proposalSortedTitles.map(prop => prop.id)).to.eql(sortedTitlesIndexes);
  });
});
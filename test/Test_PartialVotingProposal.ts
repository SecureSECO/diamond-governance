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
import { getEvents } from "../utils/utils";
import { wei } from "../utils/etherUnits";

// Types

// Other
import { Action, DiamondGovernanceClient, ProposalMetadata, VoteOption } from "../sdk/index";
import { getClient, getVotingPower } from "./Test_PartialVoting";


export async function createProposalWithClient(client : DiamondGovernanceClient, metadata : ProposalMetadata, actions : Action[]) {
  // Proposal parameters
  const startTime = 0; // 0 will get translated to block.timestamp
  const endTime = now() + 2 * days;

  const start = new Date();
  start.setTime(startTime * 1000);
  const end = new Date();
  end.setTime(endTime * 1000);

  // Create proposal
  const tx = await client.sugar.CreateProposal(metadata, actions, start, end);
  const receipt = await tx.wait();

  // Retrieve proposal information
  const IProposal = await client.pure.IProposal();
  const proposalCreationEvent = getEvents(IProposal, "ProposalCreated", receipt);
  if (proposalCreationEvent.length < 1) {
    throw new Error("Proposal creation event not found");
  }
  const proposalId = proposalCreationEvent[0].args.proposalId;
  const proposal = await client.sugar.GetProposal(proposalId, false);

  return proposal;
}

function getExampleMetaData() : ProposalMetadata {
    return {
        title: "Title",
        description: "Description",
        body: "Body",
        resources: []
    };
}

describe("PartialVotingProposal", function () {
  it("should return the same metadata on query as set", async function () {
    const client = await loadFixture(getClient);
    await getVotingPower(client);

    const metadata : ProposalMetadata = {
      title: "Title",
      description: "Description",
      body: "Body",
      resources: [{
        name: "IPFS Url",
        url: "ipfs://bafybeifzfqjybgdwyqhqxykldmtaqzvj6o26evqgifq3etgyc2ubfyh2xu/",
      }, {
        name: "Google",
        url: "https://www.google.com",
      }]
    };
    const proposal = await createProposalWithClient(client, metadata, []);
    
    expect(proposal.metadata).to.be.deep.equal(metadata);
  });

  it("should return the same actions on query as set", async function () {
    const client = await loadFixture(getClient);
    const [owner] = await ethers.getSigners();
    await getVotingPower(client);

    const actions : Action[] = [
      {
        interface: "IMintableGovernanceStructure",
        method: "mintVotingPower(address,uint256,uint256)",
        params: {
          _to: owner.address, 
          _tokenId: wei.mul(0), 
          _amount: wei.mul(25),
        }
      }
    ];
    const proposal = await createProposalWithClient(client, getExampleMetaData(), actions);
    
    expect(proposal.actions).to.be.deep.equal(actions);
  });

  it("should execute the action on execute", async function () {
    const client = await loadFixture(getClient);
    const [owner] = await ethers.getSigners();
    await getVotingPower(client);
    const mintAmount = 25;

    const actions : Action[] = [
      {
        interface: "IMintableGovernanceStructure",
        method: "mintVotingPower(address,uint256,uint256)",
        params: {
          _to: owner.address, 
          _tokenId: wei.mul(0), 
          _amount: wei.mul(mintAmount),
        }
      }
    ];
    const proposal = await createProposalWithClient(client, getExampleMetaData(), actions);
    
    const IERC20 = await client.pure.IERC20();
    const balanceBefore = await IERC20.balanceOf(owner.address);

    const voteTx = await proposal.Vote(VoteOption.Yes, balanceBefore);
    await voteTx.wait();
    await time.increaseTo(proposal.data.parameters.endDate);

    const executeTx = await proposal.Execute();
    await executeTx.wait();
    
    const balanceAfter = await IERC20.balanceOf(owner.address);

    expect(balanceAfter).to.be.deep.equal(balanceBefore.add(mintAmount));
  });

  it("should parse withdraw actions correctly", async function () {
    const client = await loadFixture(getClient);
    const [owner, random] = await ethers.getSigners();
    await getVotingPower(client);

    const ERC20Contract = await ethers.getContractFactory("ERC20");
    const ERC20 = await ERC20Contract.deploy("ERC20 TOKEN", "ERC20");

    const ERC721Contract = await ethers.getContractFactory("ERC721");
    const ERC721 = await ERC721Contract.deploy("ERC721 TOKEN", "ERC721");
  
    const ERC1155Contract = await ethers.getContractFactory("ERC1155");
    const ERC1155 = await ERC1155Contract.deploy("uri");

    const IDAOReferenceFacet = await client.pure.IDAOReferenceFacet();
    const DAOAddress = await IDAOReferenceFacet.dao();

    const actions : Action[] = [
      {
        interface: "DAO",
        method: "WithdrawNative",
        params: {
          _to: owner.address, 
          _value: wei.mul(2),
        }
      }, {
        interface: "DAO",
        method: "WithdrawERC20",
        params: {
          _from: DAOAddress,
          _to: owner.address, 
          _amount: wei.mul(7),
          _contractAddress: ERC20.address,
        }
      }, {
        interface: "DAO",
        method: "WithdrawERC20",
        params: {
          _from: random.address,
          _to: owner.address, 
          _amount: wei.mul(8),
          _contractAddress: ERC20.address,
        }
      }, {
        interface: "DAO",
        method: "WithdrawERC721",
        params: {
          _from: DAOAddress,
          _to: owner.address, 
          _tokenId: wei.mul(1),
          _contractAddress: ERC721.address,
        }
      }, {
        interface: "DAO",
        method: "WithdrawERC1155",
        params: {
          _from: DAOAddress,
          _to: owner.address, 
          _tokenId: wei.mul(6),
          _amount: wei.mul(9),
          _contractAddress: ERC1155.address,
        }
      }
    ];
    const proposal = await createProposalWithClient(client, getExampleMetaData(), actions);
    
    expect(proposal.actions).to.be.deep.equal(actions);
  });
});
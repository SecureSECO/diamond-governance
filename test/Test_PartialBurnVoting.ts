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
import { days } from "../utils/timeUnits";
import { getDeployedDiamondGovernance } from "../utils/deployedContracts";
import { DiamondCut } from "../utils/diamondGovernanceHelper";
import { createTestingDao, deployTestNetwork } from "./utils/testDeployer";
import { wei } from "../utils/etherUnits";

// Types

// Other
import { createProposalWithClient, getVotingPower } from "./Test_PartialVoting"
import { VoteOption } from "../sdk/index";


async function getClient() {
  await loadFixture(deployTestNetwork);
  const [owner] = await ethers.getSigners();
  const diamondGovernance = await getDeployedDiamondGovernance(owner);
  enum VotingMode {
      SingleVote,
      SinglePartialVote,
      MultiplePartialVote,
  }
  const PartialBurnVotingProposalFacetSettings = {
      proposalCreationCost: 1,
      _PartialVotingProposalFacetInitParams: {
          votingSettings: {
              votingMode: VotingMode.MultiplePartialVote,
              supportThreshold: 1,
              minParticipation: 1,
              maxSingleWalletPower: 10**6,
              minDuration: 1 * days,
              minProposerVotingPower: wei.mul(1),
          }
      }
  };
  const GovernanceERC20BurnableFacetSettings = {
      _GovernanceERC20FacetInitParams: {
          _ERC20VotesFacetInitParams: {
              _ERC20PermitFacetInitParams: {
                  _ERC20FacetInitParams: {
                      name: "Token",
                      symbol: "TOK",
                  }
              }
          }
      }
  };
  const cut : DiamondCut[] = [
      await DiamondCut.All(diamondGovernance.PartialBurnVotingProposalFacet, [PartialBurnVotingProposalFacetSettings]),
      await DiamondCut.All(diamondGovernance.PartialBurnVotingFacet),
      await DiamondCut.All(diamondGovernance.GovernanceERC20BurnableFacet, [GovernanceERC20BurnableFacetSettings]),
      await DiamondCut.All(diamondGovernance.AlwaysMemberTier1Facet),
  ];
  return createTestingDao(cut);
}


async function createProposal() {
  const client = await loadFixture(getClient);
  await getVotingPower(client);
  return createProposalWithClient(client);
}

describe("PartialBurnVoting", function () {
  // Simple
  it("should burn the used voting power on yes", async function () {
    const { client, proposal } = await loadFixture(createProposal);
    const IERC20 = await client.pure.IERC20();
    const [owner] = await ethers.getSigners();
    const amount = wei.mul(2);

    const balanceBefore = await IERC20.balanceOf(owner.address);
    await proposal.Vote(VoteOption.Yes, amount);
    const balanceAfter = await IERC20.balanceOf(owner.address);

    expect(balanceAfter).to.be.equal(balanceBefore.sub(amount));
  });

  it("should burn the used voting power on no", async function () {
    const { client, proposal } = await loadFixture(createProposal);
    const IERC20 = await client.pure.IERC20();
    const [owner] = await ethers.getSigners();
    const amount = wei.mul(1);

    const balanceBefore = await IERC20.balanceOf(owner.address);
    await proposal.Vote(VoteOption.No, amount);
    const balanceAfter = await IERC20.balanceOf(owner.address);

    expect(balanceAfter).to.be.equal(balanceBefore.sub(amount));
  });

  it("should burn no voting power on abstain", async function () {
    const { client, proposal } = await loadFixture(createProposal);
    const IERC20 = await client.pure.IERC20();
    const [owner] = await ethers.getSigners();
    const amount = wei.mul(4);

    const balanceBefore = await IERC20.balanceOf(owner.address);
    await proposal.Vote(VoteOption.Abstain, amount);
    const balanceAfter = await IERC20.balanceOf(owner.address);

    expect(balanceAfter).to.be.equal(balanceBefore);
  });

  it("should have less voting power after proposal creation", async function () { 
    const client = await loadFixture(getClient);
    const IERC20 = await client.pure.IERC20();
    const IBurnVotingProposalFacet = await client.pure.IBurnVotingProposalFacet();
    const [owner] = await ethers.getSigners();

    await getVotingPower(client);
    const proposalCreationCost = await IBurnVotingProposalFacet.getProposalCreationCost();
    const balanceBefore = await IERC20.balanceOf(owner.address);
    await createProposalWithClient(client);
    const balanceAfter = await IERC20.balanceOf(owner.address);

    expect(balanceAfter).to.be.equal(balanceBefore.sub(proposalCreationCost));
  });
});
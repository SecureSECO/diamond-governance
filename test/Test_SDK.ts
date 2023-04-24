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
import { deployAragonDAOAndVerifyFixture } from "../utils/verificationHelper";

// Types

// Other
import { deployAragonDAOWithFramework } from "../deployments/deploy_AragonDAO";
import { DiamondGovernanceClient } from "../sdk/index";
import { getVotingPower } from "./Test_PartialVoting";

// Tests as described in https://eips.ethereum.org/EIPS/eip-165
describe("SDK", function () {
  it("should support the ERC165 interfaceid", async function () {
    const { DiamondGovernance } = await loadFixture(deployAragonDAOWithFramework);
    const [owner] = await ethers.getSigners();

    const client = new DiamondGovernanceClient(DiamondGovernance.address, owner);
    const IERC165 = await client.pure.IERC165();
    expect(await IERC165.supportsInterface("0x01ffc9a7")).to.be.true; //ERC165 ID
  });

  it("shouldnt support an invalid interfaceid", async function () {
    const { DiamondGovernance } = await loadFixture(deployAragonDAOWithFramework);
    const [owner] = await ethers.getSigners();

    const client = new DiamondGovernanceClient(DiamondGovernance.address, owner);
    const IERC165 = await client.pure.IERC165();
    expect(await IERC165.supportsInterface("0xffffffff")).to.be.false; //INVALID ID
  });

  it("should return same metadata on proposal creation and get", async function () {
    const { DiamondGovernance } = await loadFixture(deployAragonDAOAndVerifyFixture);
    await getVotingPower(DiamondGovernance);
    const [owner] = await ethers.getSigners();

    const client = new DiamondGovernanceClient(DiamondGovernance.address, owner);
    const title = "title";
    const description = "description";
    const body = "body";
    const resource1Name = "Google";
    const resource1Url = "www.google.com";
    const metadata = {
      title: title,
      description: description,
      body: body,
      resources: [ {
        name: resource1Name,
        url: resource1Url
      }]
    };
    const start = new Date();
    start.setTime(start.getTime() + 20 * 60 * 1000); // 20 minutes
    const end = new Date();
    end.setTime(start.getTime() + 2 * 24 * 60 * 60 * 1000); // 2 days
    await client.sugar.CreateProposal(metadata, [], start, end);
    const proposals = await client.sugar.GetProposals();
    const firstProposal = await client.sugar.GetProposal(0);
    const proposalCount = await client.sugar.GetProposalCount();

    expect(proposals[0]).to.be.equal(firstProposal);
    expect(proposals).to.be.lengthOf(1);
    expect(proposalCount).to.be.equal(1);
    expect(proposals[0].metadata.title).to.be.equal(title);
    expect(proposals[0].metadata.description).to.be.equal(description);
    expect(proposals[0].metadata.body).to.be.equal(body);
    expect(proposals[0].metadata.resources).to.be.lengthOf(metadata.resources.length);
    expect(proposals[0].metadata.resources[0].name).to.be.equal(resource1Name);
    expect(proposals[0].metadata.resources[0].url).to.be.equal(resource1Url);
  });

  // Test for proposal statusses

  // Test for sorting

  it.only("actions", async function () {
    const { DiamondGovernance } = await loadFixture(deployAragonDAOAndVerifyFixture);
    await getVotingPower(DiamondGovernance);
    const [owner] = await ethers.getSigners();

    const client = new DiamondGovernanceClient(DiamondGovernance.address, owner);
    const title = "title";
    const description = "description";
    const body = "body";
    const metadata = {
      title: title,
      description: description,
      body: body,
      resources: []
    };
    const action = {
      interface: "IERC165",
      method: "supportsInterface(bytes4)",
      params: {
        interfaceId: "0xffffffff"
      }
    }
    const start = new Date();
    start.setTime(start.getTime() + 20 * 60 * 1000); // 20 minutes
    const end = new Date();
    end.setTime(start.getTime() + 2 * 24 * 60 * 60 * 1000); // 2 days
    await client.sugar.CreateProposal(metadata, [action], start, end);

    const proposal = await client.sugar.GetProposal(0);
    console.log(proposal);
  });
});
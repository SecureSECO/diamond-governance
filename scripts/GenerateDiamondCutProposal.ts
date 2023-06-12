/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  *
  * This source code is licensed under the MIT license found in the
  * LICENSE file in the root directory of this source tree.
  */

import { ethers } from "hardhat";
import { DiamondCut } from "../utils/diamondGovernanceHelper";
import { Action, DiamondGovernanceClient, ProposalMetadata } from "../sdk/index";
import { days, now } from "../utils/timeUnits";
import { getDeployedDiamondGovernance } from "../utils/deployedContracts";

const diamondGovernanceAddress = "";
const proposalMetadata : ProposalMetadata = {
  title: "Diamond cut proposal",
  description: "Example of diamond cut",
  body: "<p>Diamond cuts are pretty cool</p>",
  resources: [{
    name: "Diamond cut docs",
    url: "https://docs.secureseco.org/actions/diamond-cut",
  }],
}
const endDate = now() + 7 * days;

async function main() {
  const [owner] = await ethers.getSigners();
  const diamondGovernance = await getDeployedDiamondGovernance(owner);
  const client = new DiamondGovernanceClient(diamondGovernanceAddress, owner);

  const cut : DiamondCut[] = [
    
  ];
  const action : Action = {
    interface: "IDiamondCut",
    method: "diamondCut((address,uint8,bytes4[],bytes)[])",
    params: {
      _diamondCut: cut.map(c => c.ToBlockchain())
    }
  };

  await client.sugar.CreateProposal(proposalMetadata, [action], new Date(0), new Date(endDate * 1000));
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
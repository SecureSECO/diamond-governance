/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  *
  * This source code is licensed under the MIT license found in the
  * LICENSE file in the root directory of this source tree.
  */

import { ethers } from "hardhat";
import { DiamondGovernanceClient, ProposalMetadata } from "../sdk/index";
import { days, now } from "../utils/timeUnits";
import { ERC20, IDAO } from "../typechain-types";
import { EncodeMetadata } from "../sdk/src/sugar/proposal-metadata";
import { GetTypedContractAt } from "../utils/contractHelper";

/// Script to create a proposal with "approve Diamond Governance to spend SECOIN from the treasury" action.
/// It will also (approve and) contribute the maximumRaise and hatch the hatching contract.

const diamondGovernanceAddress = "";
const proposalMetadata : ProposalMetadata = {
  title: "Enable payout of rewards in SECOIN",
  description: "Give the Diamond Governance plugin the ability to spend SECOIN from the treasury. This allows it to reward miners and give an initial verification reward in SECOIN.",
  body: "",
  resources: [],
};
const endDate = now() + 7 * days;

async function main() {
  const [owner] = await ethers.getSigners();
  const client = new DiamondGovernanceClient(diamondGovernanceAddress, owner);

  // Approve, contribute and hatch ABC
  const hatcher = await client.sugar.GetABCHatcher();
  const hatcherState = await hatcher.getState();
  const externalToken = await GetTypedContractAt<ERC20>("ERC20", hatcherState.params.externalToken, owner);
  const contributeAmount = hatcherState.params.maximumRaise;
  const approveTx = await externalToken.approve(hatcher.address, contributeAmount);
  await approveTx.wait();
  const contributeTx = await hatcher.contribute(contributeAmount);
  await contributeTx.wait();
  const hatchTx = await hatcher.hatch();
  await hatchTx.wait();

  // Approve spending of DAO monetary token proposal
  const IMonetaryTokenFacet = await client.pure.IMonetaryTokenFacet();
  const monetaryToken = await GetTypedContractAt<ERC20>("ERC20", await IMonetaryTokenFacet.getTokenContractAddress(), owner);
  const approveData = monetaryToken.interface.encodeFunctionData("approve", [client.pure.pluginAddress, ethers.constants.MaxUint256]);
  const actions : IDAO.ActionStruct[] = [{
    to: monetaryToken.address,
    value: 0,
    data: approveData,
  }];

  const IPartialVotingProposalFacet = await client.pure.IPartialVotingProposalFacet();
  await IPartialVotingProposalFacet.createProposal(
      EncodeMetadata(proposalMetadata), 
      actions, 
      0, 
      0, 
      endDate, 
      true
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
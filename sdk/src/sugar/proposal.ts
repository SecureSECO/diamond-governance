/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  *
  * This source code is licensed under the MIT license found in the
  * LICENSE file in the root directory of this source tree.
  */

import { ProposalData, ProposalStatus, Action, ProposalMetadata, VoteOption } from "./data";
import { DecodeMetadata } from "./proposal-metadata";
import { ParseAction } from "./actions";
import { asyncMap } from "../utils";
import { DiamondGovernancePure, IPartialVotingFacet, IPartialVotingProposalFacet } from "../client";
import type { ContractTransaction } from "ethers";

/**
 * Proposal is a class that represents a proposal on the blockchain.
 */
export class Proposal {
    public id: number;
    public data: ProposalData;

    public metadata: ProposalMetadata;
    public status: ProposalStatus;
    public actions: Action[];

    private proposalContract: IPartialVotingProposalFacet;
    private voteContract: IPartialVotingFacet;

    private constructor(_id : number, _data : ProposalData, _proposalContract : IPartialVotingProposalFacet, _voteContract : IPartialVotingFacet) {
        this.id = _id;
        this.data = _data;
        this.metadata = {
          title: "",
          description: "",
          body: "",
          resources: []
        };
        this.status = ProposalStatus.Pending;
        this.actions = [];
        this.proposalContract = _proposalContract;
        this.voteContract = _voteContract;
    }

    private fromHexString(hexString : string) : Uint8Array { 
      return Uint8Array.from(Buffer.from(hexString, 'hex'));
    }
    /**
     * New proposal object from the blockchain
     * @param _id The id of the proposal
     * @param _data The data of the proposal
     * @returns {Promise<Proposal>} The proposal with the given id
     */
    public static async New(_pure : DiamondGovernancePure, _id : number, _data : ProposalData, _proposalContract : IPartialVotingProposalFacet, _voteContract : IPartialVotingFacet) : Promise<Proposal> {
        const prop = new Proposal(_id, _data, _proposalContract, _voteContract);
        prop.metadata = await DecodeMetadata(prop.fromHexString(prop.data.metadata.substring(2))); //remove 0x and convert to utf-8 array
        prop.status = prop.getStatus();
        prop.actions = await asyncMap(prop.data.actions, async (a) => await ParseAction(_pure, a));
        return prop;
    }

    /**
     * @returns {ProposalStatus} The status of the proposal
     */
    private getStatus() : ProposalStatus {
      if (this.data.executed) return ProposalStatus.Executed;
      if (this.data.open) return ProposalStatus.Active;
      if (this.data.parameters.startDate.toNumber() < Date.now()) return ProposalStatus.Pending;

      if (this.data.tally.yes.div(this.data.tally.yes.add(this.data.tally.no)).toNumber() > this.data.parameters.supportThreshold
        && this.data.tally.yes.add(this.data.tally.no) > this.data.parameters.minParticipationThresholdPower)
        return ProposalStatus.Succeeded;

      return ProposalStatus.Defeated;
    }

        /**
     * Checks if a vote is allowed on a proposal using the IPartialVotingFacet interface/contract
     * @param _voteOption Which option to vote for (Yes, No, Abstain)
     * @param _voteAmount Number of tokens to vote with
     */
      public async CanVote(_voteOption : VoteOption, _voteAmount : number) : Promise<boolean> {
        const address = await this.voteContract.signer.getAddress();
        return await this.voteContract.canVote(this.id, address, { option : _voteOption, amount : _voteAmount });
      }
  
      /**
       * Casts a vote on a proposal using the IPartialVotingFacet interface/contract
       * @param _voteOption Which option to vote for (Yes, No, Abstain)
       * @param _voteAmount Number of tokens to vote with
       */
      public async Vote(_voteOption : VoteOption, _voteAmount : number) : Promise<ContractTransaction>  {
          return await this.voteContract.vote(this.id, { option : _voteOption, amount : _voteAmount });
      }

      /**
       * Checks if this proposal can be executed
       */
      public async CanExecute() : Promise<boolean> {
        return await this.proposalContract.canExecute(this.id);
      }
      
      /**
       * Executes this proposal
       */
      public async Execute() : Promise<ContractTransaction> {
        return await this.proposalContract.execute(this.id);
      }

      /**
       * Refreshed the data
       */
      public async Refresh() {
        this.data = await this.proposalContract.getProposal(this.id);
        // metadata doesn't change
        this.status = this.getStatus();
        // actions doesn't change
      }
}
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  *
  * This source code is licensed under the MIT license found in the
  * LICENSE file in the root directory of this source tree.
  */

import { ProposalData, ProposalStatus, Action, IDAO, ProposalMetadata } from "./data";
import { DecodeMetadata } from "./proposal-metadata";
import { ParseAction } from "./actions";
import { asyncMap } from "../utils";

/**
 * Proposal is a class that represents a proposal on the blockchain.
 */
export class Proposal {
    public id: number;
    public data: ProposalData;

    public metadata: ProposalMetadata;
    public status: ProposalStatus;
    public actions: Action[];

    private constructor(_id : number, _data : ProposalData) {
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
    }

    private fromHexString(hexString : string) : Uint8Array { return Uint8Array.from(hexString.match(/.{1,2}/g)?.map((byte) => parseInt(byte, 16)) ?? new Uint8Array()); }
    /**
     * New proposal object from the blockchain
     * @param _id The id of the proposal
     * @param _data The data of the proposal
     * @returns {Promise<Proposal>} The proposal with the given id
     */
    public static async New(_id : number, _data : ProposalData) : Promise<Proposal> {
        const prop = new Proposal(_id, _data);
        prop.metadata = await DecodeMetadata(prop.fromHexString(prop.data.metadata.substring(2))); //remove 0x and convert to utf-8 array
        prop.status = prop.getStatus();
        prop.actions = await asyncMap(prop.data.actions, ParseAction);
        return prop;
    }

    public async Refresh() {
      // Seems like a useful function to support in the future
    }

    /**
     * @returns {ProposalStatus} The status of the proposal
     */
    private getStatus() : ProposalStatus {
      if (this.data.executed) return ProposalStatus.Executed;
      if (this.data.open) return ProposalStatus.Active;
      if (this.data.parameters.startDate.toNumber() < Date.now()) return ProposalStatus.Pending;

      if (this.data.tally.yes.div(this.data.tally.yes.add(this.data.tally.no)).toNumber() > this.data.parameters.supportThreshold
        && this.data.tally.yes.add(this.data.tally.no).toNumber() > this.data.parameters.minParticipation)
        return ProposalStatus.Succeeded;

      return ProposalStatus.Defeated;
    }
}
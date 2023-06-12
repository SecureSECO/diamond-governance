/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  *
  * This source code is licensed under the MIT license found in the
  * LICENSE file in the root directory of this source tree.
  */

import { asyncMap } from "../utils";
import { ProposalStatus, ProposalSorting, SortingOrder } from "./data";
import { Proposal } from "./proposal";

/**
 * ProposalCache is a cache for proposals. 
 * It can be used to get proposals by id, or to get a list of proposals. 
 * It is possible to sort and filter the proposals.
 * This reduces the amount of calls to the blockchain.
 */
export class ProposalCache {
    private proposals: Proposal[];
    private unorderedProposals: { [index: number]: Proposal };
    private getProposal: (i : number) => Promise<Proposal>;
    private getProposalCount: () => Promise<number>;
    //ProposalSorting cast to number as id, same for status (only keep track of indexes, so refreshing is easier)
    //Actually should not be allowed to cache total votes on open proposals... (Refresh all open proposal upon selecting this filter?)
    private cachedSorting: { [stat: number]: { [sort: number]: number[] } }; 

    /**
     * @param _getProposal Function to get proposal data from the blockchain
     * @param _getProposalCount Function to get the number of proposals from the blockchain
     */
    constructor(
        _getProposal : (i : number) => Promise<Proposal>, 
        _getProposalCount : () => Promise<number>
    ) {
        this.proposals = [];
        this.unorderedProposals = { };
        this.getProposal = _getProposal;
        this.getProposalCount = _getProposalCount;
        this.cachedSorting = { };
    }

    /**
     * @param until Fill the cache until this index (exclusive)
     */
    private async FillCacheUntil(until : number) {
        const indexes = [...Array(until - this.proposals.length).keys()].map(i => i + this.proposals.length);
        await asyncMap(indexes, async (index) => {
            if (this.unorderedProposals.hasOwnProperty(index)) {
                this.proposals[index] = this.unorderedProposals[index];
                delete this.unorderedProposals[index];
            } else {
                this.proposals[index] = await this.getProposal(index);
            }
        });
    }

    private async TryGetProposalFromCache(index : number) {
        if (this.unorderedProposals.hasOwnProperty(index)) {
            return this.unorderedProposals[index];
        }
        if (index < this.proposals.length) {
            return this.proposals[index];
        }

        this.unorderedProposals[index] = await this.getProposal(index);
        return this.unorderedProposals[index];
    }

    /**
     * Asynchronously retrieve the number of proposals from the blockchain
     * @returns {Promise<number>} The number of proposals
     */
    public async GetProposalCount() : Promise<number> {
        return await this.getProposalCount();
    }

    /**
     * Asynchronously retrieve the number of proposals from the blockchain with a certain status filter applied
     * @returns {Promise<number>} The number of proposals
     */
    public async GetFilteredProposalCount(status : ProposalStatus[]) : Promise<number> {
        const proposalCount = await this.GetProposalCount();
        await this.FillCacheUntil(proposalCount);

        const sorting = ProposalSorting.Creation;
        const sort = sorting as number;
        const stat = status.reduce((sum, x) => sum + x, 0);
        if (!this.cachedSorting.hasOwnProperty(stat)) {
            this.cachedSorting[stat] = { };
        }
        if (!this.cachedSorting[stat].hasOwnProperty(sort)) {
            this.cachedSorting[stat][sort] = this.proposals
                .filter(prop => status.includes(prop.status))
                .sort(this.getSortingFunc(sorting))
                .map(prop => prop.id);
        }

        return this.cachedSorting[stat][sort].length;
    }

    /**
     * Asynchronously retrieve a proposal from the blockchain
     * @param id The id of the proposal
     * @returns {Promise<Proposal>} The proposal with the given id
     */
    public async GetProposal(id : number, useCache : boolean = true) {
        const proposalCount = await this.GetProposalCount();
        if (id < 0 || id > proposalCount) {
            throw new Error("Invalid id");
        }
        
        if (!useCache) {
            return await this.getProposal(this.proposals.length);
        }

        return this.TryGetProposalFromCache(id);
    }

    /**
     * Asynchronously retrieve a list of proposals from the blockchain
     * @param status List of statuses to filter on
     * @param sorting What to sort on
     * @param order Order of results (ascending or descending)
     * @param fromIndex Index to start from
     * @param count Number of proposals to return
     * @param refreshSorting Refresh the proposals and the sorting (if false, the sorting will be cached)
     * @returns {Promise<Proposal[]>} List of proposals
     */
    public async GetProposals(status : ProposalStatus[], sorting : ProposalSorting, order : SortingOrder, fromIndex : number, count : number, refreshSorting : boolean) : Promise<Proposal[]> {
        if (status.length == Object.values(ProposalStatus).length/2 && sorting == ProposalSorting.Creation) {
            // No need to fetch all proposals for sorting / filtering
            return await this.GetProposalsEfficient(order, fromIndex, count);
        }
        
        const proposalCount = await this.GetProposalCount();
        await this.FillCacheUntil(proposalCount);

        if (refreshSorting) {
            await asyncMap(this.proposals, prop => prop.Refresh());
            this.cachedSorting = { };
        }

        const sort = sorting as number;
        const stat = status.reduce((sum, x) => sum + x, 0);
        if (!this.cachedSorting.hasOwnProperty(stat)) {
            this.cachedSorting[stat] = { };
        }
        if (!this.cachedSorting[stat].hasOwnProperty(sort)) {
            this.cachedSorting[stat][sort] = this.proposals
                .filter(prop => status.includes(prop.status))
                .sort(this.getSortingFunc(sorting))
                .map(prop => prop.id);
        }

        let proposalIds = this.cachedSorting[stat][sort];
        if (order == SortingOrder.Desc) {
            proposalIds = [...proposalIds].reverse();
        }

        return proposalIds.slice(fromIndex, fromIndex + count).map(i => this.proposals[i]);
    }

    private async GetProposalsEfficient(order : SortingOrder, fromIndex : number, count : number) : Promise<Proposal[]> {
        const proposals : number[] = [];
        const proposalCount = await this.getProposalCount();
        for (let i = 0; i < count; i++) {
            let index = fromIndex + i;
            if (order == SortingOrder.Desc) {
                index = proposalCount - 1 - index;
            }
            if (index < 0 || index >= proposalCount) break;

            proposals.push(index);
        }
        return asyncMap(proposals, p => this.TryGetProposalFromCache(p));
    }
    
    /**
     * Get a function to sort proposals
     * @param sorting What to sort on
     * @param order Order of results (ascending or descending)
     * @returns {Function} Function to sort proposals
     */
    private getSortingFunc(sorting : ProposalSorting) : (prop1: Proposal, prop2: Proposal) => number {
        const sort = (x1 : any, x2 : any) => { 
            // This can be significatly shorted with x1 - x2, but that might not work for all types (string? BigNumbers?)
            if (x1 == x2) return 0;
            else {
                if (x1 > x2) return 1;
                else return -1;
            }
        };

        let getAttribute : (prop: Proposal) => any = (prop : Proposal) => { return prop.id; }
        switch (sorting) {
            case ProposalSorting.Creation:
            default:
                break;
            case ProposalSorting.Title:
                getAttribute = (prop : Proposal) => { return prop.metadata.title; }
                break;
            case ProposalSorting.TotalVotes:
                getAttribute = (prop : Proposal) => { return prop.data.tally.abstain.add(prop.data.tally.yes).add(prop.data.tally.no); }
                break;
        }

        return (prop1 : Proposal, prop2 : Proposal) => {
            return sort(getAttribute(prop1), getAttribute(prop2));
        }
    }
}
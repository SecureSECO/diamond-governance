import { DiamondGovernancePure } from "./client";
import { ProposalStatus, ProposalSorting, SortingOrder, VoteOption, ProposalMetadata, Action, Stamp } from "./sugar/data";
import { ProposalCache } from "./sugar/proposal-cache";
import { Proposal } from "./sugar/proposal";
import { EncodeMetadata } from "./sugar/proposal-metadata";
import { ToAction } from "./sugar/actions";
import { asyncFilter, asyncMap, ToBlockchainDate } from "./utils";
import type { ContractTransaction } from "ethers";

export * from "./sugar/data"; 

export class DiamondGovernanceSugar { 
    private pure: DiamondGovernancePure;
    private proposalCache: ProposalCache | undefined;

    constructor(_pure : DiamondGovernancePure) {
        this.pure = _pure;
    }

    public async GetVerificationContractAddress() : Promise<string> {
        const IVerificationFacet = await this.pure.IVerificationFacet();
        return IVerificationFacet.getVerificationContractAddress();
    }

    /**
     * Fetch all members of the DAO 
     * @returns list of addresses that are members of the DAO
     */
    public async GetMembers() : Promise<string[]> {
        const IMembership = await this.pure.IMembership();
        const IMembershipExtended = await this.pure.IMembershipExtended();

        const possibleMembers = await IMembershipExtended.getMembers();
        return asyncFilter(possibleMembers, async member => await IMembership.isMember(member));
    }

    /**
     * Proposals are cached to reduce the number of calls to the blockchain
     * @returns {Promise<ProposalCache>} ProposalCache object
     */
    private async InitProposalCache() : Promise<ProposalCache> {
        const IProposal = await this.pure.IProposal();
        const IPartialVotingProposalFacet = await this.pure.IPartialVotingProposalFacet();
        const IPartialVotingFacet = await this.pure.IPartialVotingFacet();

        const getProposalCount = async () => (await IProposal.proposalCount()).toNumber();
        const getProposal = async (i : number) => await Proposal.New(this.pure, i, await IPartialVotingProposalFacet.getProposal(i), IPartialVotingProposalFacet, IPartialVotingFacet);

        return new ProposalCache(getProposal, getProposalCount);
    }

    /**
     * Retrieve proposals from the cache, if the cache is not initialized it will be initialized
     */
    private allStatus = [ ProposalStatus.Pending, ProposalStatus.Active, ProposalStatus.Succeeded, ProposalStatus.Executed, ProposalStatus.Defeated ];
    public async GetProposals(
        status : ProposalStatus[] = this.allStatus, 
        sorting : ProposalSorting = ProposalSorting.Creation, 
        order : SortingOrder = SortingOrder.Desc, 
        fromIndex : number = 0, 
        count : number = 10, 
        refreshSorting : boolean = false
    ) : Promise<Proposal[]> {
        if (this.proposalCache == null) {
            this.proposalCache = await this.InitProposalCache();
        }
        return await this.proposalCache.GetProposals(status, sorting, order, fromIndex, count, refreshSorting);
    }

    /**
     * Retrieve a single proposal from the cache, if the cache is not initialized it will be initialized
     * @param id Id of the proposal to retrieve
     * @returns {Promise<Proposal>} Proposal object
     */
    public async GetProposal(id : number) : Promise<Proposal> {
        if (this.proposalCache == null) {
            this.proposalCache = await this.InitProposalCache();
        }
        return await this.proposalCache.GetProposal(id);
    }

    /**
     * Retrieve the number of proposals from the cache, if the cache is not initialized it will be initialized
     * @returns {Promise<number>} Number of proposals (in the cache) -> are these all proposals or only the ones that are open?
     */
    public async GetProposalCount() : Promise<number> {
        if (this.proposalCache == null) {
            this.proposalCache = await this.InitProposalCache();
        }
        return await this.proposalCache.GetProposalCount()
    }

    /**
     * Creates a proposal using the IPartialVotingProposalFacet interface/contract
     * @param metadata Proposal metadata object (IPFS related)
     * @param actions List of actions to be executed
     * @param startDate Date the proposal will start
     * @param endDate Date the proposal will end
     */
    public async CreateProposal(metadata : ProposalMetadata, actions : Action[], startDate : Date, endDate : Date) : Promise<ContractTransaction> {
        const IPartialVotingProposalFacet = await this.pure.IPartialVotingProposalFacet();
        return await IPartialVotingProposalFacet.createProposal(
            EncodeMetadata(metadata), 
            await asyncMap(actions, (action : Action) => ToAction(this.pure, this.pure.pluginAddress, action)), 
            0, 
            ToBlockchainDate(startDate), 
            ToBlockchainDate(endDate), 
            true
        );
    }
}


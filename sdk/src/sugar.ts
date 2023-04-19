import { DiamondGovernancePure } from "./client";
import { ProposalStatus, ProposalSorting, SortingOrder, VoteOption, ProposalMetadata, Action } from "./sugar/data";
import { ProposalCache } from "./sugar/proposal-cache";
import { Proposal } from "./sugar/proposal";
import { EncodeMetadata } from "./sugar/proposal-metadata";
import { ToAction } from "./sugar/actions";
import { asyncFilter, asyncMap, ToBlockchainDate } from "./utils";

export * from "./sugar/data"; 

export class DiamondGovernanceSugar { 
    private pure: DiamondGovernancePure;
    private proposalCache: ProposalCache | undefined;

    constructor(_pure : DiamondGovernancePure) {
        this.pure = _pure;
    }

    public async GetMembers() : Promise<string[]> {
        const IMembership = await this.pure.IMembership();
        const IMembershipExtended = await this.pure.IMembershipExtended();

        const possibleMembers = await IMembershipExtended.getMembers();
        return asyncFilter(possibleMembers, async member => await IMembership.isMember(member));
    }

    private async InitProposalCache() : Promise<ProposalCache> {
        const IProposal = await this.pure.IProposal();
        const IPartialVotingProposalFacet = await this.pure.IPartialVotingProposalFacet();

        const getProposalCount = async () => (await IProposal.proposalCount()).toNumber();
        const getProposal = async (i : number) => await IPartialVotingProposalFacet.getProposal(i);

        return new ProposalCache(getProposal, getProposalCount);
    }

    private allStatus = [ ProposalStatus.Pending, ProposalStatus.Active, ProposalStatus.Succeeded, ProposalStatus.Executed, ProposalStatus.Defeated ];
    public async GetProposals(
        status : ProposalStatus[] = this.allStatus, 
        sorting : ProposalSorting = ProposalSorting.Creation, 
        order : SortingOrder = SortingOrder.Desc, 
        fromIndex : number = 0, 
        count : number = 10, 
        refreshSorting : boolean = false
    ) : Promise<Proposal[]> {
        this.proposalCache = this.proposalCache ?? await this.InitProposalCache();
        return await this.proposalCache.GetProposals(status, sorting, order, fromIndex, count, refreshSorting);
    }

    public async GetProposal(id : number) : Promise<Proposal> {
        this.proposalCache = this.proposalCache ?? await this.InitProposalCache();
        return await this.proposalCache.GetProposal(id);
    }

    public async GetProposalCount() : Promise<number> {
        this.proposalCache = this.proposalCache ?? await this.InitProposalCache();
        return await this.proposalCache.GetProposalCount()
    }

    // maybe add return type proposal id?
    public async CreateProposal(metadata : ProposalMetadata, actions : Action[], startDate : Date, endDate : Date) {
        const IPartialVotingProposalFacet = await this.pure.IPartialVotingProposalFacet();
        await IPartialVotingProposalFacet.createProposal(
            EncodeMetadata(metadata), 
            await asyncMap(actions, (action : Action) => ToAction(this.pure.pluginAddress, action)), 
            0, 
            ToBlockchainDate(startDate), 
            ToBlockchainDate(endDate), 
            true
        );
    }

    public async PartialVote(_proposalId : number, _voteOption : VoteOption, _voteAmount : number) {
        const voteContract = await this.pure.IPartialVotingFacet();

        await voteContract.vote(_proposalId, { option : _voteOption, amount : _voteAmount });
    }
}


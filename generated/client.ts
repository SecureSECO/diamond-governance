/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  *
  * This source code is licensed under the MIT license found in the
  * LICENSE file in the root directory of this source tree.
  */

import { Contract } from "ethers";
import { Signer } from "@ethersproject/abstract-signer";
import { GetTypedContractAt } from "../utils/contractHelper";
import { IERC165, IAuthProvider, IBurnVotingProposalFacet, IBurnableGovernanceStructure, IDAOReferenceFacet, IDiamondLoupe, IERC173, IERC20Metadata, IERC20MultiMinterFacet, IERC20OneTimeRewardFacet, IERC20OneTimeVerificationRewardFacet, IERC20PartialBurnVotingProposalRefundFacet, IERC20PartialBurnVotingRefundFacet, IERC20Permit, IERC20TieredTimeClaimableFacet, IERC20TimeClaimableFacet, IERC20, IERC6372, IGithubPullRequestFacet, IGovernanceStructure, IMembershipExtended, IMembershipWhitelisting, IMembership, IMintableGovernanceStructure, IPartialVotingFacet, IPartialVotingProposalFacet, IPlugin, IProposal, ITieredMembershipStructure, IVerificationFacet, IVotes } from "../typechain-types";

enum DiamondGovernanceInterfaces { IERC165, IAuthProvider, IBurnVotingProposalFacet, IBurnableGovernanceStructure, IDAOReferenceFacet, IDiamondLoupe, IERC173, IERC20Metadata, IERC20MultiMinterFacet, IERC20OneTimeRewardFacet, IERC20OneTimeVerificationRewardFacet, IERC20PartialBurnVotingProposalRefundFacet, IERC20PartialBurnVotingRefundFacet, IERC20Permit, IERC20TieredTimeClaimableFacet, IERC20TimeClaimableFacet, IERC20, IERC6372, IGithubPullRequestFacet, IGovernanceStructure, IMembershipExtended, IMembershipWhitelisting, IMembership, IMintableGovernanceStructure, IPartialVotingFacet, IPartialVotingProposalFacet, IPlugin, IProposal, ITieredMembershipStructure, IVerificationFacet, IVotes }

class DiamondGovernancePure {
    public pluginAddress : string;
    public signer : Signer;
    private cache: { [id: string] : Contract }

    public constructor(_pluginAddress : string, _signer : Signer) {
        this.pluginAddress = _pluginAddress;
        this.signer = _signer;
        this.cache = { };
        Object.freeze(this);
    }

    public async IERC165() : Promise<IERC165> {
        return await this._get<IERC165>(DiamondGovernanceInterfaces.IERC165, "");
    }
    
    public async IAuthProvider() : Promise<IAuthProvider> {
        return await this._get<IAuthProvider>(DiamondGovernanceInterfaces.IAuthProvider, "0xb2aee3b9");
    }

    public async IBurnVotingProposalFacet() : Promise<IBurnVotingProposalFacet> {
        return await this._get<IBurnVotingProposalFacet>(DiamondGovernanceInterfaces.IBurnVotingProposalFacet, "0x87ffa625");
    }

    public async IBurnableGovernanceStructure() : Promise<IBurnableGovernanceStructure> {
        return await this._get<IBurnableGovernanceStructure>(DiamondGovernanceInterfaces.IBurnableGovernanceStructure, "0x85d9cf86");
    }

    public async IDAOReferenceFacet() : Promise<IDAOReferenceFacet> {
        return await this._get<IDAOReferenceFacet>(DiamondGovernanceInterfaces.IDAOReferenceFacet, "0x4162169f");
    }

    public async IDiamondLoupe() : Promise<IDiamondLoupe> {
        return await this._get<IDiamondLoupe>(DiamondGovernanceInterfaces.IDiamondLoupe, "0x48e2b093");
    }

    public async IERC173() : Promise<IERC173> {
        return await this._get<IERC173>(DiamondGovernanceInterfaces.IERC173, "0x7f5828d0");
    }

    public async IERC20Metadata() : Promise<IERC20Metadata> {
        return await this._get<IERC20Metadata>(DiamondGovernanceInterfaces.IERC20Metadata, "0xa219a025");
    }

    public async IERC20MultiMinterFacet() : Promise<IERC20MultiMinterFacet> {
        return await this._get<IERC20MultiMinterFacet>(DiamondGovernanceInterfaces.IERC20MultiMinterFacet, "0x14004ef3");
    }

    public async IERC20OneTimeRewardFacet() : Promise<IERC20OneTimeRewardFacet> {
        return await this._get<IERC20OneTimeRewardFacet>(DiamondGovernanceInterfaces.IERC20OneTimeRewardFacet, "0x8c5c884c");
    }

    public async IERC20OneTimeVerificationRewardFacet() : Promise<IERC20OneTimeVerificationRewardFacet> {
        return await this._get<IERC20OneTimeVerificationRewardFacet>(DiamondGovernanceInterfaces.IERC20OneTimeVerificationRewardFacet, "0xf61c53c0");
    }

    public async IERC20PartialBurnVotingProposalRefundFacet() : Promise<IERC20PartialBurnVotingProposalRefundFacet> {
        return await this._get<IERC20PartialBurnVotingProposalRefundFacet>(DiamondGovernanceInterfaces.IERC20PartialBurnVotingProposalRefundFacet, "0x4aabfd6c");
    }

    public async IERC20PartialBurnVotingRefundFacet() : Promise<IERC20PartialBurnVotingRefundFacet> {
        return await this._get<IERC20PartialBurnVotingRefundFacet>(DiamondGovernanceInterfaces.IERC20PartialBurnVotingRefundFacet, "0x91e2ebbe");
    }

    public async IERC20Permit() : Promise<IERC20Permit> {
        return await this._get<IERC20Permit>(DiamondGovernanceInterfaces.IERC20Permit, "0x9d8ff7da");
    }

    public async IERC20TieredTimeClaimableFacet() : Promise<IERC20TieredTimeClaimableFacet> {
        return await this._get<IERC20TieredTimeClaimableFacet>(DiamondGovernanceInterfaces.IERC20TieredTimeClaimableFacet, "0x3a17fed2");
    }

    public async IERC20TimeClaimableFacet() : Promise<IERC20TimeClaimableFacet> {
        return await this._get<IERC20TimeClaimableFacet>(DiamondGovernanceInterfaces.IERC20TimeClaimableFacet, "0x065b0962");
    }

    public async IERC20() : Promise<IERC20> {
        return await this._get<IERC20>(DiamondGovernanceInterfaces.IERC20, "0x36372b07");
    }

    public async IERC6372() : Promise<IERC6372> {
        return await this._get<IERC6372>(DiamondGovernanceInterfaces.IERC6372, "0xda287a1d");
    }

    public async IGithubPullRequestFacet() : Promise<IGithubPullRequestFacet> {
        return await this._get<IGithubPullRequestFacet>(DiamondGovernanceInterfaces.IGithubPullRequestFacet, "0xa1ff1300");
    }

    public async IGovernanceStructure() : Promise<IGovernanceStructure> {
        return await this._get<IGovernanceStructure>(DiamondGovernanceInterfaces.IGovernanceStructure, "0x217205e6");
    }

    public async IMembershipExtended() : Promise<IMembershipExtended> {
        return await this._get<IMembershipExtended>(DiamondGovernanceInterfaces.IMembershipExtended, "0x2a21f601");
    }

    public async IMembershipWhitelisting() : Promise<IMembershipWhitelisting> {
        return await this._get<IMembershipWhitelisting>(DiamondGovernanceInterfaces.IMembershipWhitelisting, "0x9b19251a");
    }

    public async IMembership() : Promise<IMembership> {
        return await this._get<IMembership>(DiamondGovernanceInterfaces.IMembership, "0xa230c524");
    }

    public async IMintableGovernanceStructure() : Promise<IMintableGovernanceStructure> {
        return await this._get<IMintableGovernanceStructure>(DiamondGovernanceInterfaces.IMintableGovernanceStructure, "0x03520be9");
    }

    public async IPartialVotingFacet() : Promise<IPartialVotingFacet> {
        return await this._get<IPartialVotingFacet>(DiamondGovernanceInterfaces.IPartialVotingFacet, "0xe7ce0a62");
    }

    public async IPartialVotingProposalFacet() : Promise<IPartialVotingProposalFacet> {
        return await this._get<IPartialVotingProposalFacet>(DiamondGovernanceInterfaces.IPartialVotingProposalFacet, "0xd8c3cea7");
    }

    public async IPlugin() : Promise<IPlugin> {
        return await this._get<IPlugin>(DiamondGovernanceInterfaces.IPlugin, "0x41de6830");
    }

    public async IProposal() : Promise<IProposal> {
        return await this._get<IProposal>(DiamondGovernanceInterfaces.IProposal, "0xda35c664");
    }

    public async ITieredMembershipStructure() : Promise<ITieredMembershipStructure> {
        return await this._get<ITieredMembershipStructure>(DiamondGovernanceInterfaces.ITieredMembershipStructure, "0xdea631ee");
    }

    public async IVerificationFacet() : Promise<IVerificationFacet> {
        return await this._get<IVerificationFacet>(DiamondGovernanceInterfaces.IVerificationFacet, "0x40cd79b9");
    }

    public async IVotes() : Promise<IVotes> {
        return await this._get<IVotes>(DiamondGovernanceInterfaces.IVotes, "0xe90fb3f6");
    }

    public async GetCustomInterface(_name : string, _abi : any[], _interfaceId : string | undefined) : Promise<Contract> {
        if (this.cache.hasOwnProperty(_name)) {
            return this.cache[_name];
        }

        if (_interfaceId != undefined) {
            const ierc165 = await this.IERC165();
            const isSupported = await ierc165.supportsInterface(_interfaceId);
            if (!isSupported) {
                throw new Error("Interface not supported by the diamond");
            }
        }
        
        const contract = new Contract(this.pluginAddress, _abi, this.signer);
        this.cache[_name] = contract;
        return contract;
    }

    private async _get<Type extends Contract>(_interface : DiamondGovernanceInterfaces, _interfaceId : string) : Promise<Type> {
        if (this.cache.hasOwnProperty(_interface)) {
            return this.cache[_interface] as Type;
        }
        
        if (_interface !== DiamondGovernanceInterfaces.IERC165) {
            if (_interfaceId === null || _interfaceId === undefined) {
                throw new Error("InterfaceId not provided");
            }
            
            const ierc165 = await this.IERC165();
            const isSupported = await ierc165.supportsInterface(_interfaceId);
            if (!isSupported) {
                throw new Error("Interface not supported by the diamond");
            }
        }

        const name = DiamondGovernanceInterfaces[_interface];
        const contract = await GetTypedContractAt<Type>(name, this.pluginAddress, this.signer);
        this.cache[name] = contract;
        return contract;
    }
}

export { DiamondGovernanceInterfaces, DiamondGovernancePure, IERC165, IAuthProvider, IBurnVotingProposalFacet, IBurnableGovernanceStructure, IDAOReferenceFacet, IDiamondLoupe, IERC173, IERC20Metadata, IERC20MultiMinterFacet, IERC20OneTimeRewardFacet, IERC20OneTimeVerificationRewardFacet, IERC20PartialBurnVotingProposalRefundFacet, IERC20PartialBurnVotingRefundFacet, IERC20Permit, IERC20TieredTimeClaimableFacet, IERC20TimeClaimableFacet, IERC20, IERC6372, IGithubPullRequestFacet, IGovernanceStructure, IMembershipExtended, IMembershipWhitelisting, IMembership, IMintableGovernanceStructure, IPartialVotingFacet, IPartialVotingProposalFacet, IPlugin, IProposal, ITieredMembershipStructure, IVerificationFacet, IVotes }
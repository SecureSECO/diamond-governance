// Framework
import { ethers } from "hardhat";

// Utils

// Types

// Other

// addresses of deployed libraries
interface Libraries {
    VerificationFacetInit: string;
    PartialVotingProposalFacetInit: string;
    ERC20TimeClaimableFacetInit: string;
    ERC20TieredTimeClaimableFacetInit: string;
}

async function deployLibraries() : Promise<Libraries> {
    const VerificationFacetInitContract = await ethers.getContractFactory("VerificationFacetInit");
    const VerificationFacetInit = await VerificationFacetInitContract.deploy();

    const PartialVotingProposalFacetInitContract = await ethers.getContractFactory("PartialVotingProposalFacetInit");
    const PartialVotingProposalFacetInit = await PartialVotingProposalFacetInitContract.deploy();

    const ERC20TimeClaimableFacetInitContract = await ethers.getContractFactory("ERC20TimeClaimableFacetInit");
    const ERC20TimeClaimableFacetInit = await ERC20TimeClaimableFacetInitContract.deploy();
    
    const ERC20TieredTimeClaimableFacetInitContract = await ethers.getContractFactory("ERC20TieredTimeClaimableFacetInit", { 
        libraries: {
            ERC20TimeClaimableFacetInit: ERC20TimeClaimableFacetInit.address 
        }
    });
    const ERC20TieredTimeClaimableFacetInit = await ERC20TieredTimeClaimableFacetInitContract.deploy();

    return {
        VerificationFacetInit: VerificationFacetInit.address,
        PartialVotingProposalFacetInit: PartialVotingProposalFacetInit.address,
        ERC20TimeClaimableFacetInit: ERC20TimeClaimableFacetInit.address,
        ERC20TieredTimeClaimableFacetInit: ERC20TieredTimeClaimableFacetInit.address
    };
}

export { deployLibraries };
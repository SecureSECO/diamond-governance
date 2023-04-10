/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  *
  * This source code is licensed under the MIT license found in the
  * LICENSE file in the root directory of this source tree.
  */

// Framework
import { ethers } from "hardhat";

// Utils

// Types

// Other

// addresses of deployed libraries
interface Libraries {
    DAOReferenceFacetInit: string;
    PartialVotingProposalFacetInit: string;
    PartialBurnVotingProposalFacetInit: string;
    VerificationFacetInit: string;
    ERC20TimeClaimableFacetInit: string;
    ERC20TieredTimeClaimableFacetInit: string;
    ERC20OneTimeRewardFacetInit: string;
    ERC20OneTimeVerificationRewardFacetInit: string;
}

async function deployLibraries() : Promise<Libraries> {
    const DAOReferenceFacetInitContract = await ethers.getContractFactory("DAOReferenceFacetInit");
    const DAOReferenceFacetInit = await DAOReferenceFacetInitContract.deploy();

    const PartialVotingProposalFacetInitContract = await ethers.getContractFactory("PartialVotingProposalFacetInit");
    const PartialVotingProposalFacetInit = await PartialVotingProposalFacetInitContract.deploy();
    
    const PartialBurnVotingProposalFacetInitContract = await ethers.getContractFactory("PartialBurnVotingProposalFacetInit", { 
        libraries: {
            PartialVotingProposalFacetInit: PartialVotingProposalFacetInit.address 
        }
    });
    const PartialBurnVotingProposalFacetInit = await PartialBurnVotingProposalFacetInitContract.deploy();

    const VerificationFacetInitContract = await ethers.getContractFactory("VerificationFacetInit");
    const VerificationFacetInit = await VerificationFacetInitContract.deploy();

    const ERC20TimeClaimableFacetInitContract = await ethers.getContractFactory("ERC20TimeClaimableFacetInit");
    const ERC20TimeClaimableFacetInit = await ERC20TimeClaimableFacetInitContract.deploy();
    
    const ERC20TieredTimeClaimableFacetInitContract = await ethers.getContractFactory("ERC20TieredTimeClaimableFacetInit", { 
        libraries: {
            ERC20TimeClaimableFacetInit: ERC20TimeClaimableFacetInit.address 
        }
    });
    const ERC20TieredTimeClaimableFacetInit = await ERC20TieredTimeClaimableFacetInitContract.deploy();

    const ERC20OneTimeRewardFacetInitContract = await ethers.getContractFactory("ERC20OneTimeRewardFacetInit");
    const ERC20OneTimeRewardFacetInit = await ERC20OneTimeRewardFacetInitContract.deploy();
    
    const ERC20OneTimeVerificationRewardFacetInitContract = await ethers.getContractFactory("ERC20OneTimeVerificationRewardFacetInit", { 
        libraries: {
            ERC20OneTimeRewardFacetInit: ERC20OneTimeRewardFacetInit.address 
        }
    });
    const ERC20OneTimeVerificationRewardFacetInit = await ERC20OneTimeVerificationRewardFacetInitContract.deploy();

    return {
        DAOReferenceFacetInit: DAOReferenceFacetInit.address,
        PartialVotingProposalFacetInit: PartialVotingProposalFacetInit.address,
        PartialBurnVotingProposalFacetInit: PartialBurnVotingProposalFacetInit.address,
        VerificationFacetInit: VerificationFacetInit.address,
        ERC20TimeClaimableFacetInit: ERC20TimeClaimableFacetInit.address,
        ERC20TieredTimeClaimableFacetInit: ERC20TieredTimeClaimableFacetInit.address,
        ERC20OneTimeRewardFacetInit: ERC20OneTimeRewardFacetInit.address,
        ERC20OneTimeVerificationRewardFacetInit: ERC20OneTimeVerificationRewardFacetInit.address,
    };
}

export { deployLibraries };
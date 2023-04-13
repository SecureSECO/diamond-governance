// SPDX-License-Identifier: MIT
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  */

pragma solidity ^0.8.0;

/******************************************************************************\
* Author: Nick Mudge <nick@perfectabstractions.com> (https://twitter.com/mudgen)
* EIP-2535 Diamonds: https://eips.ethereum.org/EIPS/eip-2535
*
* Implementation of a diamond.
/******************************************************************************/

import { 
    IERC165,
    IERC20,
    IERC20Metadata,
    IERC20Permit,

    IERC173,
    IERC6372,
    IVotes,
    IDiamondLoupe,

    IPlugin,
    IAuthProvider,

    IGovernanceStructure,
    IMintableGovernanceStructure,
    IBurnableGovernanceStructure,

    IMembership,
    IMembershipExtended,
    ITieredMembershipStructure,
    
    IPartialVotingProposalFacet,
    IPartialVotingFacet 
} from "../utils/InterfaceIds.sol";

import { PartialBurnVotingProposalFacetInit } from "../facets/governance/proposal/PartialBurnVotingProposalFacet.sol";
import { VerificationFacetInit } from "../facets/membership/VerificationFacet.sol";
import { ERC20TieredTimeClaimableFacetInit } from "../facets/token/ERC20/claiming/time/ERC20TieredTimeClaimableFacet.sol";
import { ERC20OneTimeVerificationRewardFacetInit } from "../facets/token/ERC20/claiming/one-time/ERC20OneTimeVerificationRewardFacet.sol";
import { SearchSECOMonetizationFacetInit } from "../facets/securesecoMonetization/SearchSECOMonetizationFacet.sol";

import { LibDiamond } from "../libraries/LibDiamond.sol";
import { LibPartialVotingProposalStorage } from "../libraries/storage/LibPartialVotingProposalStorage.sol";

// It is expected that this contract is customized if you want to deploy your diamond
// with data from a deployment script. Use the init function to initialize state variables
// of your diamond. Add parameters to the init funciton if you need to.

contract DiamondInit {    
    // You can add parameters to this function in order to pass in 
    // data to set your own state variables
    function init(
        PartialBurnVotingProposalFacetInit.InitParams memory _votingSettings, 
        VerificationFacetInit.InitParams memory _verificationSettings, 
        ERC20TieredTimeClaimableFacetInit.InitParams memory _timeClaimSettings,
        ERC20OneTimeVerificationRewardFacetInit.InitParams memory _onetimeClaimSettings,
        SearchSECOMonetizationFacetInit.InitParams memory _searchSECOMonetizationSettings
    ) external {
        // adding ERC165 data
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        ds.supportedInterfaces[type(IERC165).interfaceId] = true;
        ds.supportedInterfaces[type(IERC20).interfaceId] = true;
        ds.supportedInterfaces[type(IERC20Metadata).interfaceId] = true;
        ds.supportedInterfaces[type(IERC20Permit).interfaceId] = true;
        
        ds.supportedInterfaces[type(IERC173).interfaceId] = true;
        ds.supportedInterfaces[type(IERC6372).interfaceId] = true;
        ds.supportedInterfaces[type(IVotes).interfaceId] = true;
        ds.supportedInterfaces[type(IDiamondLoupe).interfaceId] = true;

        ds.supportedInterfaces[type(IPlugin).interfaceId] = true;
        ds.supportedInterfaces[type(IAuthProvider).interfaceId] = true;

        ds.supportedInterfaces[type(IGovernanceStructure).interfaceId] = true;
        ds.supportedInterfaces[type(IMintableGovernanceStructure).interfaceId] = true;
        ds.supportedInterfaces[type(IBurnableGovernanceStructure).interfaceId] = true;

        ds.supportedInterfaces[type(IMembership).interfaceId] = true;
        ds.supportedInterfaces[type(IMembershipExtended).interfaceId] = true;
        ds.supportedInterfaces[type(ITieredMembershipStructure).interfaceId] = true;

        ds.supportedInterfaces[type(IPartialVotingProposalFacet).interfaceId] = true;
        ds.supportedInterfaces[type(IPartialVotingFacet).interfaceId] = true;

        // add your own state variables 
        // EIP-2535 specifies that the `diamondCut` function takes two optional 
        // arguments: address _init and bytes calldata _calldata
        // These arguments are used to execute an arbitrary function using delegatecall
        // in order to set state variables in the diamond during deployment or an upgrade
        // More info here: https://eips.ethereum.org/EIPS/eip-2535#diamond-interface 

        PartialBurnVotingProposalFacetInit.init(_votingSettings);
        VerificationFacetInit.init(_verificationSettings);
        ERC20TieredTimeClaimableFacetInit.init(_timeClaimSettings);
        ERC20OneTimeVerificationRewardFacetInit.init(_onetimeClaimSettings);
        SearchSECOMonetizationFacetInit.init(_searchSECOMonetizationSettings);
    }
}
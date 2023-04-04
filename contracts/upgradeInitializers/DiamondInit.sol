// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/******************************************************************************\
* Author: Nick Mudge <nick@perfectabstractions.com> (https://twitter.com/mudgen)
* EIP-2535 Diamonds: https://eips.ethereum.org/EIPS/eip-2535
*
* Implementation of a diamond.
/******************************************************************************/

import { IERC165 } from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IERC20Metadata } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import { IERC20Permit } from "@openzeppelin/contracts/token/ERC20/extensions/draft-IERC20Permit.sol";
import { IPlugin } from "@aragon/osx/core/plugin/IPlugin.sol";

import { IERC173 } from "../additional-contracts/IERC173.sol";
import { IERC5805 } from "../additional-contracts/IERC5805.sol";
import { IDiamondLoupe } from "../additional-contracts/IDiamondLoupe.sol";

import { IMintableGovernanceStructure } from "../facets/governance/structure/voting-power/IMintableGovernanceStructure.sol";
import { IBurnableGovernanceStructure } from "../facets/governance/structure/voting-power/IBurnableGovernanceStructure.sol";
import { ITieredMembershipStructure } from "../facets/governance/structure/membership/ITieredMembershipStructure.sol";
import { IPartialVotingProposalFacet } from "../facets/governance/proposal/IPartialVotingProposalFacet.sol";
import { IPartialVotingFacet } from "../facets/governance/voting/IPartialVotingFacet.sol";

import { VerificationFacetInit } from "../facets/membership/VerificationFacet.sol";
import { PartialVotingProposalFacetInit } from "../facets/governance/proposal/PartialVotingProposalFacet.sol";
import { ERC20TieredTimeClaimableFacetInit } from "../facets/token/ERC20/claiming/ERC20TieredTimeClaimableFacet.sol";

import { LibDiamond } from "../libraries/LibDiamond.sol";
import { LibVerificationStorage } from "../libraries/storage/LibVerificationStorage.sol";
import { LibPartialVotingProposalStorage } from "../libraries/storage/LibPartialVotingProposalStorage.sol";

// It is expected that this contract is customized if you want to deploy your diamond
// with data from a deployment script. Use the init function to initialize state variables
// of your diamond. Add parameters to the init funciton if you need to.

contract DiamondInit {    
    // You can add parameters to this function in order to pass in 
    // data to set your own state variables
    function init(
        VerificationFacetInit.InitParams memory _verificationSettings, 
        PartialVotingProposalFacetInit.InitParams memory _votingSettings, 
        ERC20TieredTimeClaimableFacetInit.InitParams memory _claimSettings
    ) external {
        // adding ERC165 data
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        ds.supportedInterfaces[type(IERC165).interfaceId] = true;
        ds.supportedInterfaces[type(IERC20).interfaceId] = true;
        ds.supportedInterfaces[type(IERC20Metadata).interfaceId] = true;
        ds.supportedInterfaces[type(IERC20Permit).interfaceId] = true;
        ds.supportedInterfaces[type(IPlugin).interfaceId] = true;
        
        ds.supportedInterfaces[type(IERC173).interfaceId] = true;
        ds.supportedInterfaces[type(IERC5805).interfaceId] = true;
        ds.supportedInterfaces[type(IDiamondLoupe).interfaceId] = true;

        ds.supportedInterfaces[type(IMintableGovernanceStructure).interfaceId] = true;
        ds.supportedInterfaces[type(IBurnableGovernanceStructure).interfaceId] = true;
        ds.supportedInterfaces[type(ITieredMembershipStructure).interfaceId] = true;
        ds.supportedInterfaces[type(IPartialVotingProposalFacet).interfaceId] = true;
        ds.supportedInterfaces[type(IPartialVotingFacet).interfaceId] = true;

        // add your own state variables 
        // EIP-2535 specifies that the `diamondCut` function takes two optional 
        // arguments: address _init and bytes calldata _calldata
        // These arguments are used to execute an arbitrary function using delegatecall
        // in order to set state variables in the diamond during deployment or an upgrade
        // More info here: https://eips.ethereum.org/EIPS/eip-2535#diamond-interface 

        VerificationFacetInit.init(_verificationSettings);
        PartialVotingProposalFacetInit.init(_votingSettings);
        ERC20TieredTimeClaimableFacetInit.init(_claimSettings);
    }
}
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

import { IMintableGovernanceStructure } from "../facets/governance/structure/IMintableGovernanceStructure.sol";
import { IBurnableGovernanceStructure } from "../facets/governance/structure/IBurnableGovernanceStructure.sol";
import { IPartialVotingProposalFacet } from "../facets/governance/proposal/IPartialVotingProposalFacet.sol";
import { IPartialVotingFacet } from "../facets/governance/voting/IPartialVotingFacet.sol";

import { GovernanceERC20Facet } from "../facets/token/ERC20/governance/GovernanceERC20Facet.sol";
import { PartialVotingProposalFacet } from "../facets/governance/proposal/PartialVotingProposalFacet.sol";

import { LibDiamond } from "../libraries/LibDiamond.sol";
import { LibVerificationStorage } from "../libraries/storage/LibVerificationStorage.sol";
import { LibPartialVotingProposalStorage } from "../libraries/storage/LibPartialVotingProposalStorage.sol";

// It is expected that this contract is customized if you want to deploy your diamond
// with data from a deployment script. Use the init function to initialize state variables
// of your diamond. Add parameters to the init funciton if you need to.

contract DiamondInit {    
    // You can add parameters to this function in order to pass in 
    // data to set your own state variables
    function init(address _verificationContractAddress, IPartialVotingProposalFacet.VotingSettings memory _votingSettings) external {
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
        ds.supportedInterfaces[type(IPartialVotingProposalFacet).interfaceId] = true;
        ds.supportedInterfaces[type(IPartialVotingFacet).interfaceId] = true;

        // add your own state variables 
        // EIP-2535 specifies that the `diamondCut` function takes two optional 
        // arguments: address _init and bytes calldata _calldata
        // These arguments are used to execute an arbitrary function using delegatecall
        // in order to set state variables in the diamond during deployment or an upgrade
        // More info here: https://eips.ethereum.org/EIPS/eip-2535#diamond-interface 

        LibVerificationStorage.VerificationStorage storage vds = LibVerificationStorage.verificationStorage();
        // TODO: specify contract address
        vds.verificationContractAddress = _verificationContractAddress;
        
        LibPartialVotingProposalStorage.PartialVotingProposalStorage storage partialVotingProposalStorage = 
            LibPartialVotingProposalStorage.partialVotingProposalStorage();
        partialVotingProposalStorage.votingSettings = _votingSettings;
    }
}
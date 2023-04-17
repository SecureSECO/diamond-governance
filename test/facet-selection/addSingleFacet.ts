import { DiamondDeployedContractsBase, addFacetToDiamondWithInit } from "../../deployments/deploy_DGSelection";
import { deployStandaloneVerificationContract } from "../../deployments/deploy_StandaloneVerificationContract";

const searchSecoMonetization = async (diamondGovernanceContracts: DiamondDeployedContractsBase, diamondGovernanceAddress: string) => {
  // Contract names
  const contractNames = {
    facetContractName: "SearchSECOMonetizationFacet",
    facetInitContractName: "SearchSECOMonetizationFacetInit",
    diamondInitName: "DISearchSECOMonetization",
  }

  // Deploy facet contract
  const searchSECOMonetizationSettings = {
    hashCost: 1,
  }
  await addFacetToDiamondWithInit(diamondGovernanceContracts, diamondGovernanceAddress, contractNames, searchSECOMonetizationSettings);
}

const verification = async (diamondGovernanceContracts: DiamondDeployedContractsBase, diamondGovernanceAddress: string) => {
  // Deploy standalone contract
  const StandaloneVerificationContract = await deployStandaloneVerificationContract();

  // Contract names
  const contractNames = {
    facetContractName: "VerificationFacet",
    facetInitContractName: "VerificationFacetInit",
    diamondInitName: "DIVerification",
  }

  // Deploy facet contract
  const settings = {
    verificationContractAddress: StandaloneVerificationContract.address, //address
    providers: ["github", "proofofhumanity"], //string[]
    rewards: [3, 10], //uint256[]
  };
  await addFacetToDiamondWithInit(diamondGovernanceContracts, diamondGovernanceAddress, contractNames, settings);
}

export { searchSecoMonetization, verification }
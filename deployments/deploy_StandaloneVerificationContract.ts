// Framework
import { ethers } from "hardhat";

// Utils

// Types
import {GithubVerification} from "../typechain-types";

// Other
const VERIFICATION_DAY_THRESHOLD = 60;

export const deployStandaloneVerificationContract = async () : Promise<GithubVerification> => {
  const StandaloneVerificationContract = await ethers.getContractFactory("GithubVerification");
  const StandaloneVerification = await StandaloneVerificationContract.deploy(VERIFICATION_DAY_THRESHOLD);
  console.log(`VerificationFacet deployed at ${StandaloneVerification.address}`);

  return StandaloneVerification;
}

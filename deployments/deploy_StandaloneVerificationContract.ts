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
import {GithubVerification} from "../typechain-types";

// Other
const VERIFICATION_DAY_THRESHOLD = 60;
const REVERIFICATION_THRESHOLD = 30;

export const deployStandaloneVerificationContract = async () : Promise<GithubVerification> => {
  const StandaloneVerificationContract = await ethers.getContractFactory("GithubVerification");
  const StandaloneVerification = await StandaloneVerificationContract.deploy(VERIFICATION_DAY_THRESHOLD, REVERIFICATION_THRESHOLD);
  console.log(`Standalone verification contract deployed at ${StandaloneVerification.address}`);

  return StandaloneVerification;
}
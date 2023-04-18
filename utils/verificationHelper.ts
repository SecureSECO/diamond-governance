// Framework
import { ethers } from "hardhat";

// Tests
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";

// Utils
import { createSignature } from "./signatureHelper";
import { now } from "./timeUnits";

// Types

// Other
import { deployAragonDAOWithFramework } from "../deployments/deploy_AragonDAO";

async function verify(verificationContractAddress : string) {
  const [owner] = await ethers.getSigners();
  const standaloneVerificationContract = await ethers.getContractAt("GithubVerification", verificationContractAddress);

  // Manually verify owner with github
  const timestamp = now();
  const userHash =
    "090d4910f4b4038000f6ea86644d55cb5261a1dc1f006d928dcc049b157daff8";
  const dataHexString = await createSignature(timestamp, owner.address, userHash, owner);
  await standaloneVerificationContract.verifyAddress(owner.address, userHash, timestamp, "github", dataHexString);
}

async function deployAragonDAOAndVerifyFixture() {
    const { DiamondGovernance, diamondGovernanceContracts, verificationContractAddress, DAO } = await loadFixture(deployAragonDAOWithFramework);
    await verify(verificationContractAddress);
    return { DiamondGovernance, diamondGovernanceContracts, verificationContractAddress, DAO };
}

export { verify, deployAragonDAOAndVerifyFixture }
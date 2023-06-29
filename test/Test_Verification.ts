/**
 * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
 * © Copyright Utrecht University (Department of Information and Computing Sciences)
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

// Framework
import { ethers } from "hardhat";

// Tests
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";

// Utils
import { getDeployedDiamondGovernance } from "../utils/deployedContracts";
import { createTestingDao, deployTestNetwork } from "./utils/testDeployer";
import { DiamondCut } from "../utils/diamondGovernanceHelper";
import { now } from "../utils/timeUnits";
import { createSignature } from "../utils/signatureHelper";

// Types

// Other

async function getClient() {
  await loadFixture(deployTestNetwork);
  const [owner] = await ethers.getSigners();
  const diamondGovernance = await getDeployedDiamondGovernance(owner);
  
  // Providers and rewards are not used in this test
  const verificationSettings = {
    verificationContractAddress: diamondGovernance.SignVerification.address,
    providers: ["github"],
    rewards: [1],
  }
  const cut: DiamondCut[] = [
    await DiamondCut.All(diamondGovernance.VerificationFacet, [verificationSettings]),
  ];
  return createTestingDao(cut);
}

// Very basic test to check if integration went successfully
describe("SignVerification", () => {
  it("should verify an account", async () => {
    const client = await loadFixture(getClient);
    const IVerificationFacet = await client.pure.IVerificationFacet();
    const verificationContractAddress = await IVerificationFacet.getVerificationContractAddress();

    const [owner] = await ethers.getSigners();
    const standaloneVerificationContract = await ethers.getContractAt("SignVerification", verificationContractAddress);

    // Manually verify owner with github
    const timestamp = now();
    const userHash =
      "090d4910f4b4038000f6ea86644d55cb5261a1dc1f006d928dcc049b157daff8";
    const dataHexString = await createSignature(timestamp, owner.address, userHash, owner);

    // Throws if verification fails
    await standaloneVerificationContract.verifyAddress(owner.address, userHash, timestamp, "github", dataHexString);

    // Check if verification is successful
    const stamps = await standaloneVerificationContract.getStamps(owner.address);
    expect(stamps.length).to.equal(1);
  });
  it("should get/set correctly", async () => {
    const client = await loadFixture(getClient);
    const IVerificationFacet = await client.pure.IVerificationFacet();
    const verificationContractAddress = await IVerificationFacet.getVerificationContractAddress();
    const standaloneVerificationContract = await ethers.getContractAt("SignVerification", verificationContractAddress);

    await standaloneVerificationContract.transferOwnership(client.pure.pluginAddress); // Transfer to diamond governance

    await IVerificationFacet.setReverifyThreshold(1);
    expect(await IVerificationFacet.getReverifyThreshold()).to.equal(1);

    await IVerificationFacet.setVerifyThreshold(1);
    expect(await IVerificationFacet.getVerifyThreshold()).to.equal(1);
  });
  // This doesn't actually assert anything, just tests if the functions don't throw
  it("sdk verification sugar tests", async () => {
    const client = await loadFixture(getClient);
    const [owner] = await ethers.getSigners();

    // Manually verify owner with github
    const timestamp = now();
    const userHash =
      "090d4910f4b4038000f6ea86644d55cb5261a1dc1f006d928dcc049b157daff8";
    const dataHexString = await createSignature(timestamp, owner.address, userHash, owner);
    await client.verification.Verify(owner.address, userHash, timestamp, "github", dataHexString);

    await client.verification.GetThresholdHistory();
    await client.verification.GetStamps(owner.address);
  });
});
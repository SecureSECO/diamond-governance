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
import { GetTypedContractAt } from "../utils/contractHelper";
import { AuthConsumerTestFacet } from "../typechain-types";

// Types

// Other

async function getClient() {
  await loadFixture(deployTestNetwork);
  const [owner] = await ethers.getSigners();
  const diamondGovernance = await getDeployedDiamondGovernance(owner);
  const cut : DiamondCut[] = [
    await DiamondCut.All(diamondGovernance.DiamondCutFacet),
    await DiamondCut.All(diamondGovernance.DiamondLoupeFacet),
    await DiamondCut.All(diamondGovernance.DAOReferenceFacet),
    await DiamondCut.All(diamondGovernance.PluginFacet),
    await DiamondCut.All(diamondGovernance.AragonAuthFacet),
    await DiamondCut.All(diamondGovernance.AuthConsumerTestFacet),
  ];
  return createTestingDao(cut, false);
  }

describe("AragonAuthFacet", () => {
  it("should allow the plugin itself", async () => {
    const client = await loadFixture(getClient);
    const signer = await ethers.getImpersonatedSigner(client.pure.pluginAddress);
    client.pure.signer.sendTransaction({ to: signer.address, value: ethers.utils.parseEther("1")}); // Smart contract by default has no funds to pay for gas
    const AuthConsumerTestFacet = await GetTypedContractAt<AuthConsumerTestFacet>("AuthConsumerTestFacet", client.pure.pluginAddress, signer);

    expect(await AuthConsumerTestFacet.hasExecuted()).to.be.false;
    await AuthConsumerTestFacet.Execute();
    expect(await AuthConsumerTestFacet.hasExecuted()).to.be.true;
  });

  it("should allow the dao", async () => {
    const client = await loadFixture(getClient);
    const IDAOReferenceFacet = await client.pure.IDAOReferenceFacet();
    const DAOAddress = await IDAOReferenceFacet.dao();
    const signer = await ethers.getImpersonatedSigner(DAOAddress);
    client.pure.signer.sendTransaction({ to: signer.address, value: ethers.utils.parseEther("1")}); // Smart contract by default has no funds to pay for gas
    const AuthConsumerTestFacet = await GetTypedContractAt<AuthConsumerTestFacet>("AuthConsumerTestFacet", client.pure.pluginAddress, signer);

    expect(await AuthConsumerTestFacet.hasExecuted()).to.be.false;
    await AuthConsumerTestFacet.Execute();
    expect(await AuthConsumerTestFacet.hasExecuted()).to.be.true;
  });
  
  it("shouldn't allow a different address", async () => {
    const client = await loadFixture(getClient);
    const AuthConsumerTestFacet = await GetTypedContractAt<AuthConsumerTestFacet>("AuthConsumerTestFacet", client.pure.pluginAddress, client.pure.signer);

    expect(await AuthConsumerTestFacet.hasExecuted()).to.be.false;
    expect(AuthConsumerTestFacet.Execute()).to.be.reverted;
    expect(await AuthConsumerTestFacet.hasExecuted()).to.be.false;
  });
});
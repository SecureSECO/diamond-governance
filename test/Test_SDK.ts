// Framework
import { ethers } from "hardhat";

// Tests
import { expect } from "chai";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";

// Utils

// Types

// Other
import { deployAragonDAO } from "../deployments/deploy_AragonDAO";
import { DiamondGovernanceClient } from "../sdk/client";

// Tests as described in https://eips.ethereum.org/EIPS/eip-165
describe("SDK ERC165", function () {
  it("should support the ERC165 interfaceid", async function () {
    const { DiamondGovernance } = await loadFixture(deployAragonDAO);
    const [owner] = await ethers.getSigners();

    const client = new DiamondGovernanceClient(DiamondGovernance.address, owner);
    const IERC165 = await client.IERC165();
    expect(await IERC165.supportsInterface("0x01ffc9a7")).to.be.true; //ERC165 ID
  });

  it("shouldnt support an invalid interfaceid", async function () {
    const { DiamondGovernance } = await loadFixture(deployAragonDAO);
    const [owner] = await ethers.getSigners();

    const client = new DiamondGovernanceClient(DiamondGovernance.address, owner);
    const IERC165 = await client.IERC165();
    expect(await IERC165.supportsInterface("0xffffffff")).to.be.false; //INVALID ID
  });
});
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
import { expect } from "chai";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";

// Utils

// Types

// Other
import { deployAragonDAOWithFramework } from "../deployments/deploy_AragonDAO";
import { DiamondGovernanceClient } from "../sdk/src/client";

// Tests as described in https://eips.ethereum.org/EIPS/eip-165
describe("SDK ERC165", function () {
  it("should support the ERC165 interfaceid", async function () {
    const { DiamondGovernance } = await loadFixture(deployAragonDAOWithFramework);
    const [owner] = await ethers.getSigners();

    const client = new DiamondGovernanceClient(DiamondGovernance.address, owner);
    const IERC165 = await client.IERC165();
    expect(await IERC165.supportsInterface("0x01ffc9a7")).to.be.true; //ERC165 ID
  });

  it("shouldnt support an invalid interfaceid", async function () {
    const { DiamondGovernance } = await loadFixture(deployAragonDAOWithFramework);
    const [owner] = await ethers.getSigners();

    const client = new DiamondGovernanceClient(DiamondGovernance.address, owner);
    const IERC165 = await client.IERC165();
    expect(await IERC165.supportsInterface("0xffffffff")).to.be.false; //INVALID ID
  });
});
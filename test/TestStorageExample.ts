// Framework

// Tests
import { expect } from "chai";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";

// Utils

// Types

// Other
import { deployStorageExample } from "../deployments/deploy_StorageExample";

describe("StorageExample contract", function () {
  it("Initial number after deployment shoud be 3", async function () {
    const { StorageExample } = await loadFixture(deployStorageExample);

    expect(await StorageExample.variable()).to.equal(3);
  });

  it("Set and get variable should return same number", async function () {
    const { StorageExample } = await loadFixture(deployStorageExample);
    const number = 5;

    await StorageExample.setVariable(number);

    expect(await StorageExample.variable()).to.equal(number);
  });
});
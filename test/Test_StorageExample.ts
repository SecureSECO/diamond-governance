/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  *
  * This source code is licensed under the MIT license found in the
  * LICENSE file in the root directory of this source tree.
  */

// Framework

// Tests
import { expect } from "chai";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";

// Utils

// Types

// Other
import { deployStorageExample } from "../deployments/deploy_StorageExample";

describe("StorageExample", function () {
  it("initial number after deployment shoud be 3", async function () {
    const { StorageExample } = await loadFixture(deployStorageExample);

    expect(await StorageExample.variable()).to.equal(3);
  });

  it("should return the set number after a set and get operation", async function () {
    const { StorageExample } = await loadFixture(deployStorageExample);
    const number = 5;

    await StorageExample.setVariable(number);

    expect(await StorageExample.variable()).to.equal(number);
  });
});
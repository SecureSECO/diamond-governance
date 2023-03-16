const StorageExampleContract = artifacts.require("StorageExample");

contract("StorageExample", (accounts) => {
  it("should start with value 3", async () => {
    const StorageExample = await StorageExampleContract.deployed();

    const initialValue = 3;

    assert.equal(await StorageExample.variable(), initialValue, "Contract should have 3 before doing any sets");
  });

  it("should get the same value after set", async () => {
    const StorageExample = await StorageExampleContract.deployed();

    const value = 5;

    await StorageExample.setVariable(value);

    assert.equal(await StorageExample.variable(), value, "Get after set gives different value");
  });

  it("should get the same value after two sets", async () => {
    const StorageExample = await StorageExampleContract.deployed();

    const fakeValue = 9;
    const value = 7;

    await StorageExample.setVariable(fakeValue);
    await StorageExample.setVariable(value);

    assert.equal(await StorageExample.variable(), value, "Get after set after set gives different value");
  });
});

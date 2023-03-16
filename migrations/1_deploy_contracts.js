var StorageExampleContract = artifacts.require("StorageExample");

module.exports = async function(deployer) {
  // deployment steps
  await deployer.deploy(StorageExampleContract);
  var StorageExample = await StorageExampleContract.deployed();
  await StorageExample.setVariable(3);
};

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.8.17;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../../../contracts/examples/StorageExample.sol";

contract TestStorageExample {
  StorageExample instance = StorageExample(DeployedAddresses.StorageExample());

  function testInitThree() public {
    uint initValue = 3;

    Assert.equal(instance.variable, initValue, "Contract should have 3 before doing any sets");
  }

  function testSetGet() public {
    uint value = 5;

    instance.setVariable(value);

    Assert.equal(instance.variable, value, "Get after set gives different value");
  }

  function testSetSetGet() public {
    uint fakeValue = 9;
    uint value = 7;

    instance.setVariable(fakeValue);
    instance.setVariable(value);

    Assert.equal(instance.variable, value, "Get after set after set gives different value");
  }
}

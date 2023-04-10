/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  *
  * This source code is licensed under the MIT license found in the
  * LICENSE file in the root directory of this source tree.
  */

// Framework
import { ethers } from "hardhat";

// Utils

// Types

// Other

/**
 * Deploys a StorageExample contract and sets the intial configuration
 * @returns The newly deployed StorageExample contract
 */
async function deployStorageExample() {
    const StorageExampleContract = await ethers.getContractFactory("StorageExample");

    const StorageExample = await StorageExampleContract.deploy();

    await StorageExample.setVariable(3);

    return { StorageExample };
}

export { deployStorageExample }
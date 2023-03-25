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
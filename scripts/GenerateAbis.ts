/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  *
  * This source code is licensed under the MIT license found in the
  * LICENSE file in the root directory of this source tree.
  */

import fs from "fs";
import hre from "hardhat";

/// Script to copy hardhat artifacts to abis.json, so ethers contracts can be made based on contract name without needing hardhat.

const outputFile = "./generated/abis.json";

async function main() {
  console.log("Start copying abis from artifacts...");
  let abis : { [name : string] : any[] } = { };
  const artifactNames = await hre.artifacts.getAllFullyQualifiedNames();
  for (let i = 0; i < artifactNames.length; i++) {
    const artifact = await hre.artifacts.readArtifact(artifactNames[i]);
    abis[artifact.contractName] = artifact.abi;
  }

  fs.writeFileSync(outputFile, JSON.stringify(abis));
  console.log("Finished creating abis.json");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
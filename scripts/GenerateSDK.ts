/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  *
  * This source code is licensed under the MIT license found in the
  * LICENSE file in the root directory of this source tree.
  */

import fs from "fs";
import { generateInterfaceIds } from "./sdk/GenerateInterfaceIds";
import { GetContractAt } from "../utils/contractHelper";
import { ethers } from "hardhat";
import { getSelectors } from "../utils/diamondHelper";

const insertInterfaces = "/* interfaces */";
const insertMethods = "/* interface methods */";
const templateFile = "./generated/client-template.ts";
const outputFile = "./generated/client.ts";
const reverseSelectorFile = "./generated/functionSelectors.json";

async function generateInterfaceMethod(interfaceName : string, interfaceId : string) : Promise<string> {
    return `
    public async ${interfaceName}() : Promise<${interfaceName}> {
        return await this._get<${interfaceName}>(DiamondGovernanceInterfaces.${interfaceName}, "${interfaceId}");
    }`;
}

async function main() {
    console.log("Started generating of SDK");
    const [owner] = await ethers.getSigners();
    const interfaceIds = await generateInterfaceIds();
    const interfaceKeys = Object.keys(interfaceIds);

    let interfaceMethodArray = [];
    let reverseFunctionSelectorLookup : { [selector: string]: string} = {};
    for (let i = 0; i < interfaceKeys.length; i++) {
        const name = interfaceKeys[i];
        interfaceMethodArray.push(await generateInterfaceMethod(name, interfaceIds[name]));

        const contract = await GetContractAt(name, ethers.constants.AddressZero, owner);
        const selectors = getSelectors(contract).selectors;
        for (let j = 0; j < selectors.length; j++) {
            reverseFunctionSelectorLookup[selectors[j]] = name;
        }
    }
    
    const interfaces = interfaceKeys.join(", ");
    const methods = interfaceMethodArray.join("\n");

    const template = fs.readFileSync(templateFile, 'utf-8');
    const newClient = template.replaceAll(insertInterfaces, interfaces).replaceAll(insertMethods, methods);

    fs.writeFileSync(outputFile, newClient);
    fs.writeFileSync(reverseSelectorFile, JSON.stringify(reverseFunctionSelectorLookup));
    console.log("Finished generating of SDK with", interfaceKeys.length, "interfaces");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
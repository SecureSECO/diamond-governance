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
import { functionSelectorsJson, variableSelectorsJson } from "../utils/jsonTypes";

const insertInterfaces = "/* interfaces */";
const insertMethods = "/* interface methods */";
const templateFile = "./generated/client-template.ts";
const outputFile = "./generated/client.ts";
const reverseSelectorFile = "./generated/functionSelectors.json";
const variableSelectorFile = "./generated/variableSelectors.json";

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
    let reverseFunctionSelectorLookup : functionSelectorsJson = {};
    let variableSelectors : variableSelectorsJson = {};
    for (let i = 0; i < interfaceKeys.length; i++) {
        const name = interfaceKeys[i];
        interfaceMethodArray.push(await generateInterfaceMethod(name, interfaceIds[name]));

        const contract = await GetContractAt(name, ethers.constants.AddressZero, owner);
        //reverseFunctionSelectorLookup
        const selectors = getSelectors(contract).selectors;
        for (let j = 0; j < selectors.length; j++) {
            reverseFunctionSelectorLookup[selectors[j]] = name;
        }

        //variableSelectors
        const functions = Object.keys(contract.interface.functions);
        for (let j = 0; j < functions.length; j++) {
            // Is not a get function (getX(args))
            if (!functions[j].startsWith("get")) { continue; }
            const variableName = functions[j].split('(')[0].substring(3);

            // There exists no set function (setX(args)) 
            const setFunctionIndex = functions.findIndex(f => f.startsWith("set" + variableName));
            if (setFunctionIndex === -1) { continue; }

            const getFunctionFrag = contract.interface.functions[functions[j]];
            // Get functions with inputs currently not supported
            if (getFunctionFrag.inputs.length > 0) { continue; }

            // Get function without output is illegal
            if (getFunctionFrag.outputs == undefined) { console.warn("Variable get function for", variableName, "has no outputs"); continue; }
            if (getFunctionFrag.outputs.length < 0) { console.warn("Variable get function for", variableName, "has no outputs"); continue; }
            if (getFunctionFrag.outputs.length > 1) { console.warn("Variable get function for", variableName, "has more than 1 output"); continue; }

            // Check if set function matches the get function and follows the programming patterns
            const setFunctionFrag = contract.interface.functions[functions[setFunctionIndex]];
            if (setFunctionFrag.inputs.length < 0) { console.warn("Variable set function for", variableName, "has no inputs"); continue; }
            if (setFunctionFrag.inputs.length > 1) { console.warn("Variable set function for", variableName, "has more than 1 input"); continue; }
            if (setFunctionFrag.inputs[0].type !== getFunctionFrag.outputs[0].type) {
                console.warn("Variable get and set function for", variableName, "have different types for out and input"); 
                continue; 
            }
            if (setFunctionFrag.inputs[0].name !== "_" + firstLetterToLowercase(variableName)) {
                console.warn("Variable set function for", variableName, "does not follow pattern of _variableName"); 
                continue;
            }

            variableSelectors[contract.interface.getSighash(functions[j])] = {
                facetName: name,
                variableName: variableName,
                variableType: getFunctionFrag.outputs[0].format("full"),
                setSelector: contract.interface.getSighash(functions[setFunctionIndex]),
            };
        }
    }
    
    const interfaces = interfaceKeys.join(", ");
    const methods = interfaceMethodArray.join("\n");

    const template = fs.readFileSync(templateFile, 'utf-8');
    const newClient = template.replaceAll(insertInterfaces, interfaces).replaceAll(insertMethods, methods);

    fs.writeFileSync(outputFile, newClient);
    fs.writeFileSync(reverseSelectorFile, JSON.stringify(reverseFunctionSelectorLookup));
    fs.writeFileSync(variableSelectorFile, JSON.stringify(variableSelectors));
    console.log("Finished generating of SDK with", interfaceKeys.length, "interfaces");
}

function firstLetterToLowercase(str : string) : string {
    return str.charAt(0).toLowerCase() + str.slice(1);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
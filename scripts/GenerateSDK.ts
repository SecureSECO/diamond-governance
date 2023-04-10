/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  *
  * This source code is licensed under the MIT license found in the
  * LICENSE file in the root directory of this source tree.
  */

import fs from "fs";
import { generateInterfaceIds } from "./sdk/GenerateInterfaceIds";

const insertInterfaces = "/* interfaces */";
const insertMethods = "/* interface methods */";
function generateInterfaceMethod(interfaceName : string, interfaceId : string) {
    return `
    public async ${interfaceName}() : Promise<${interfaceName}> {
        return await this._get<${interfaceName}>(DiamondGovernanceInterfaces.${interfaceName}, "${interfaceId}");
    }`;
}

async function main() {
    console.log("Started generating of SDK");
    const interfaceIds = await generateInterfaceIds();
    const interfaceKeys = Object.keys(interfaceIds);
    console.log("Interfaces detected: ", interfaceIds);

    let interfaceMethodArray = [];
    for (let i = 0; i < interfaceKeys.length; i++) {
        const name = interfaceKeys[i];
        interfaceMethodArray.push(generateInterfaceMethod(name, interfaceIds[name]));
    }
    
    const interfaces = interfaceKeys.join(", ");
    const methods = interfaceMethodArray.join("\n");

    const template = fs.readFileSync("./sdk/client-template.ts", 'utf-8');
    const newClient = template.replaceAll(insertInterfaces, interfaces).replaceAll(insertMethods, methods);

    fs.writeFileSync("./sdk/client.ts", newClient);
    console.log("Finished generating of SDK");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
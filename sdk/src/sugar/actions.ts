/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  *
  * This source code is licensed under the MIT license found in the
  * LICENSE file in the root directory of this source tree.
  */

import { IDAO, Action } from "./data";
import { ethers } from "hardhat";
import { DiamondGovernanceInterfaces } from "../client";
import { FunctionFragment, Interface, ParamType } from "@ethersproject/abi";
import { arrayify } from "@ethersproject/bytes";

// Source: https://github.com/aragon/sdk/blob/60edc9e36ba58909391085153f6a5c2a2f4c5e9c/modules/client/src/client-common/encoding.ts#L63
function getFunctionFragment(
  data: Uint8Array,
  availableFunctions: string[],
): FunctionFragment {
  const hexBytes = bytesToHex(data);
  const iface = new Interface(availableFunctions);
  return iface.getFunction(hexBytes.substring(0, 10));
}

// Source: https://github.com/aragon/sdk/blob/60edc9e36ba58909391085153f6a5c2a2f4c5e9c/modules/common/src/encoding.ts#L24
export function bytesToHex(buff: Uint8Array, skip0x?: boolean): string {
  const bytes: string[] = [];
  for (let i = 0; i < buff.length; i++) {
    if (buff[i] >= 16) bytes.push(buff[i].toString(16));
    else bytes.push("0" + buff[i].toString(16));
  }
  if (skip0x) return bytes.join("");
  return "0x" + bytes.join("");
}

/**
 * Converts an Action object (interface, method, params) to an ActionStruct (to, value, data) that can be used in the Aragon SDK
 * @param toAddress Address of the contract that should execute the action
 * @param action Action (interface, method, params) object
 * @returns {Promise<IDAO.ActionStruct>} ActionStruct object
 */
export async function ToAction(toAddress : string, action : Action) : Promise<IDAO.ActionStruct> {
    const contract = await ethers.getContractAt(action.interface, ethers.constants.AddressZero);
    const inputs = await contract.interface.functions[action.method].inputs;
    const args = inputs.map((input : ParamType) => action.params[input.name]);
    const calldata = await contract.interface.encodeFunctionData(action.method, args);
    return {
      to: toAddress,
      // idk if the value is an information field? In the Aragon SDK it is zero everywhere
      // This is the native token value, this should be zero assuming it isn't a paid function
      value: Object.keys(DiamondGovernanceInterfaces).indexOf(action.interface) + 1, 
      data: calldata
    };
}

/**
 * Parses an ActionStruct from Aragon SDK to an Action object (interface, method, params)
 * @param action ActionStruct from Aragon SDK
 * @returns {Promise<Action>} Action object
 */
export async function ParseAction(action : IDAO.ActionStruct) : Promise<Action> {
    if (action.value == 0) {
      return {
        interface: "Unsupported",
        method: "Likely made by Aragon SDK",
        params: { }
      };
    }

    const hexBytes = bytesToHex(arrayify(await action.data));
    const contractName = Object.keys(DiamondGovernanceInterfaces)[(action.value as any).toNumber() - 1];
    const contract =  await ethers.getContractAt(contractName, ethers.constants.AddressZero);
    const method = contract.interface.getFunction(hexBytes.substring(0, 10));
    const fullMethodName = method.name + "(" + method.inputs.map((input : ParamType) => input.type).join(",") + ")";
    const inputData = await contract.interface.decodeFunctionData(method, await action.data)
    const params : { [name: string]: any } = { };
    for (let i = 0; i < inputData.length; i++) {
      params[method.inputs[i].name] = inputData[i];
    }

    return {
      interface: contractName,
      method: fullMethodName,
      params: params
    };
}
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  *
  * This source code is licensed under the MIT license found in the
  * LICENSE file in the root directory of this source tree.
  */

import { IDAO, Action } from "./data";
import { ParamType } from "@ethersproject/abi";
import { arrayify } from "@ethersproject/bytes";
import { GetAbi, GetTypedContractAt, ReverseFunctionSelectorLookup } from "../../../utils/contractHelper";
import { ethers } from "ethers";
import { Signer } from "@ethersproject/abstract-signer";
import { IDAOReferenceFacet, IERC165 } from "../../../typechain-types";

/// File that handles encoding and decoding of actions.

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
export async function ToAction(contracts : any, pluginAddress : string, action : Action, signer : Signer) : Promise<IDAO.ActionStruct> {
  if (action.interface == "DAO") {
    if (action.method == "WithdrawNative") {
      return {
        to: action.params._to,
        value: action.params._value,
        data: new Uint8Array()
      };
    }
    else if (action.method == "WithdrawERC20") {
      const IERC20 = new ethers.utils.Interface(GetAbi("IERC20"));

      const IDAOReferenceFacet = await contracts["IDAOReferenceFacet"]() as IDAOReferenceFacet;
      const DAOAddress = await IDAOReferenceFacet.dao();
      const data = action.params._from == DAOAddress ?
        await IERC20.encodeFunctionData("transfer", [action.params._to, action.params._amount]) :
        await IERC20.encodeFunctionData("transferFrom(address,address,uint256)", [action.params._from, action.params._to, action.params._amount]);

      return {
        to: action.params._contractAddress,
        value: 0,
        data: data
      };
    }
    else if (action.method == "ApproveERC20") {
      const IERC20 = new ethers.utils.Interface(GetAbi("IERC20"));
      const data = await IERC20.encodeFunctionData("approve", [action.params.spender, action.params.amount]);

      return {
        to: action.params._contractAddress,
        value: 0,
        data: data
      };
    }
    else if (action.method == "WithdrawERC721") {
      const IERC721 = new ethers.utils.Interface(GetAbi("IERC721"));
      return {
        to: action.params._contractAddress,
        value: 0,
        data: await IERC721.encodeFunctionData("transferFrom(address,address,uint256)", [action.params._from, action.params._to, action.params._tokenId])
      };
    }
    else if (action.method == "WithdrawERC1155") {
      const IERC1155 = new ethers.utils.Interface(GetAbi("IERC1155"));
      return {
        to: action.params._contractAddress,
        value: 0,
        data: await IERC1155.encodeFunctionData("safeTransferFrom(address,address,uint256,uint256,bytes)", [action.params._from, action.params._to, action.params._tokenId, action.params._amount, '0x'])
      };
    }
  }

  const contract = await contracts[action.interface]();
  const inputs = await contract.interface.functions[action.method].inputs;
  const args = inputs.map((input : ParamType) => action.params[input.name]);
  const calldata = await contract.interface.encodeFunctionData(action.method, args);
  return {
    to: pluginAddress,
    value: 0, 
    data: calldata
  };
}

/**
 * Parses an ActionStruct from Aragon SDK to an Action object (interface, method, params)
 * @param action ActionStruct from Aragon SDK
 * @returns {Promise<Action>} Action object
 */
export async function ParseAction(contracts : any, pluginAddress : string, action : IDAO.ActionStruct, signer : Signer) : Promise<Action> {
  // The action is not a Diamond Governance interaction
  if (await action.to != pluginAddress) {
    // The action sends native currency
    if ((await action.value).toString() != "0") {
      return {
        interface: "DAO",
        method: "WithdrawNative",
        params: {
          _to: action.to,
          _value: action.value
        }
      };
    }
    else {
      const hexBytes = bytesToHex(arrayify(await action.data));
      const funcSelector = hexBytes.substring(0, 10);
      if (funcSelector == "0xa9059cbb") { //transfer
        const IERC20 = new ethers.utils.Interface(GetAbi("IERC20"));
        const paramData = IERC20.decodeFunctionData("transfer(address,uint256)", await action.data);
        const IDAOReferenceFacet = await contracts["IDAOReferenceFacet"]() as IDAOReferenceFacet;
        const DAOAddress = await IDAOReferenceFacet.dao();
        return {
          interface: "DAO",
          method: "WithdrawERC20",
          params: {
            _from: DAOAddress,
            _to: paramData[0],
            _amount: paramData[1],
            _contractAddress: await action.to
          }
        };
      } else if (funcSelector == "0x23b872dd") { //transferFrom
        // This function is implemented with the same signature on both IERC20 as IERC721 (only the parameters have different meaning)
        // IERC721 requires IERC165 support, we will use this to check if it's an IERC721
        const IERC165 = await GetTypedContractAt<IERC165>("IERC165", await action.to, signer);
        try {
          // Calling this on an IERC20 contract might give an error
          const supportsIERC721 = await IERC165.supportsInterface("0x80ac58cd");
          if (!supportsIERC721) {
            throw new Error("Not IERC721");
          }

          const IERC721 = new ethers.utils.Interface(GetAbi("IERC721"));
          const paramData = IERC721.decodeFunctionData("transferFrom(address,address,uint256)", await action.data);
          return {
            interface: "DAO",
            method: "WithdrawERC721",
            params: {
              _from: paramData[0],
              _to: paramData[1],
              _tokenId: paramData[2],
              _contractAddress: await action.to
            }
          };
        }
        catch {
          const IERC20 = new ethers.utils.Interface(GetAbi("IERC20"));
          const paramData = IERC20.decodeFunctionData("transferFrom(address,address,uint256)", await action.data);
          return {
            interface: "DAO",
            method: "WithdrawERC20",
            params: {
              _from: paramData[0],
              _to: paramData[1],
              _amount: paramData[2],
              _contractAddress: await action.to
            }
          };
        }
      } else if (funcSelector == "0xf242432a") { //safeTransferFrom
        const IERC1155 = new ethers.utils.Interface(GetAbi("IERC1155"));
        const paramData = IERC1155.decodeFunctionData("safeTransferFrom(address,address,uint256,uint256,bytes)", await action.data);
        return {
          interface: "DAO",
          method: "WithdrawERC1155",
          params: {
            _from: paramData[0],
            _to: paramData[1],
            _tokenId: paramData[2],
            _amount: paramData[3],
            _contractAddress: await action.to
          }
        };
      } else if (funcSelector == "0x095ea7b3") { //approve
        const IERC20 = new ethers.utils.Interface(GetAbi("IERC20"));
        const paramData = IERC20.decodeFunctionData("approve(address,uint256)", await action.data);
        return {
          interface: "DAO",
          method: "ApproveERC20",
          params: {
            spender: paramData[0],
            amount: paramData[1],
            _contractAddress: await action.to
          }
        };
      }
      else {
        // Unkown action, not much we can here
        return {
          interface: "Contract" + await action.to,
          method: "Function" + funcSelector,
          params: { }
        };
      }
    }
  }

  const hexBytes = bytesToHex(arrayify(await action.data));
  const funcSelector = hexBytes.substring(0, 10);
  const contractName = ReverseFunctionSelectorLookup(funcSelector);
  const contract = await contracts[contractName]();
  const method = contract.interface.getFunction(funcSelector);
  const fullMethodName = method.name + "(" + method.inputs.map((input : ParamType) => input.type).join(",") + ")";
  const inputData = await contract.interface.decodeFunctionData(method, await action.data);
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
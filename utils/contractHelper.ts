/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  *
  * This source code is licensed under the MIT license found in the
  * LICENSE file in the root directory of this source tree.
  */

import { Contract } from "ethers";
import { Signer } from "@ethersproject/abstract-signer";
import abisJson from "../generated/abis.json";

export class NamedContract extends Contract {
  public contractName: string;

  constructor(name : string, address : string, signer : Signer) {
    super(address, GetAbi(name), signer);
    this.contractName = name;
  }
}

export function NameContract(name : string, contract : Contract) : NamedContract  {
  return new NamedContract(name, contract.address, contract.signer);
}

export async function GetContractAt(name : string, address : string, signer : Signer) : Promise<NamedContract> {
  return new NamedContract(name, address, signer);
}

export async function GetTypedContractAt<T extends Contract>(name : string, address : string, signer : Signer) : Promise<T & NamedContract> {
  return await GetContractAt(name, address, signer) as T & NamedContract;
}

export function GetAbi(name : string) : any[] {
  const abis = abisJson as { [contractName : string]: any[] };
  if (!abis.hasOwnProperty(name)) {
    throw new Error(`Abi of contract ${name} not found, perhaps you need to regenerate abis.json?`);
  }

  return abis[name];
}
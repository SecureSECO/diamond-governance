/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  *
  * This source code is licensed under the MIT license found in the
  * LICENSE file in the root directory of this source tree.
  */

// Framework
import { ethers, Contract, ContractReceipt } from "ethers";
import { id } from "@ethersproject/hash";

// Utils

// Types

// Other

export function toBytes(str : string) : string {
    return ethers.utils.hexlify(ethers.utils.toUtf8Bytes(str));
}

export function getEvents(contract : Contract, eventName : string, receipt : ContractReceipt) : ethers.utils.LogDescription[] {
    const event = id(contract.interface.getEvent(eventName).format("sighash"));
    const logsOfEvent = receipt.logs.filter(e => e.topics[0] === event);
    return logsOfEvent.map(log => contract.interface.parseLog(log));
}
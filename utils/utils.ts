// Framework
import { ethers } from "hardhat";
import { id } from "@ethersproject/hash";

// Utils

// Types

// Other

export function toBytes(str : string) : string {
    return ethers.utils.hexlify(ethers.utils.toUtf8Bytes(str));
}

export function getEvents(contract : any, eventName : string, receipt : any) {
    const event = id(contract.interface.getEvent(eventName).format("sighash"));
    const logsOfEvent = receipt.logs?.filter((e : any) => e.topics[0] === event);
    return logsOfEvent.map((log : any) => contract.interface.parseLog(log));
}
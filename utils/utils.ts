import { ethers } from "hardhat";

export function toBytes(str : string) : string {
    return ethers.utils.hexlify(ethers.utils.toUtf8Bytes(str));
}
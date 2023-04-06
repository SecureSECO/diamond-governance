// Framework
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { ethers } from "hardhat";

/**
 *
 * @param {number} timestamp Timestamp at which the proof is made
 * @param {string} toVerify Account address to verify
 * @param {string} ownerPrivKey Private key of the signer
 * @returns
 */
export const createSignature = async (timestamp: number, toVerify: string, userHash: string, owner: SignerWithAddress) => {
  const packedMessage = ethers.utils.solidityPack(
    ["address", "string", "uint256"], [toVerify, userHash, timestamp]
  );

  const hashPackedMessage = ethers.utils.keccak256(packedMessage);

  return owner.signMessage(ethers.utils.arrayify(hashPackedMessage));
};
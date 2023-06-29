/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  *
  * This source code is licensed under the MIT license found in the
  * LICENSE file in the root directory of this source tree.
  */
 
// Framework
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { ethers } from "ethers";

/// Helper to sign messsages with proof that an offchain action was performed.

/**
 *
 * @param {number} timestamp Timestamp at which the proof is made
 * @param {string} toVerify Account address to verify
 * @param {string} ownerPrivKey Private key of the signer
 * @returns
 */
export const createSignature = async (timestamp: number, toVerify: string, userHash: string, owner: SignerWithAddress, providerId = "github") => {
  const packedMessage = ethers.utils.solidityPack(
    ["address", "string", "uint256", "string"], [toVerify, userHash, timestamp, providerId]
  );

  const hashPackedMessage = ethers.utils.keccak256(packedMessage);

  return owner.signMessage(ethers.utils.arrayify(hashPackedMessage));
};

export const createSignatureRewarding = async (toReward: string, hashCount: number, nonce: number, owner: SignerWithAddress) => {
  const packedMessage = ethers.utils.solidityPack(
    ["address", "uint256", "uint256"], [toReward, hashCount, nonce]
  );

  const hashPackedMessage = ethers.utils.keccak256(packedMessage);

  return owner.signMessage(ethers.utils.arrayify(hashPackedMessage));
}
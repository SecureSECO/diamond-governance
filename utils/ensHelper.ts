// Framework
import { ethers } from "hardhat";

//Utils

//Types
import { PublicResolver } from "../typechain-types";

//Other

/**
 * Encodes the node string according to ENS spec
 * (ethers.utils.namehash)
 * @param node The node in string form
 * @returns The node encoded according to ENS spec
 */
function toEnsNode(node : string) : string {
    return ethers.utils.namehash(node);
}

/**
 * Encodes the label string according to ENS spec
 * (ethers.utils.keccak256(ethers.utils.toUtf8Bytes(label)))
 * @param label The label in string form
 * @returns The label encoded according to ENS spec
 */
function toEnsLabel(label : string) : string {
    return ethers.utils.keccak256(ethers.utils.toUtf8Bytes(label));
}

/**
 * Asks the resolver for the address stored at subdomain.domain
 * Calls the .addr(bytes32) function of the smart contract
 * @param resolver The resolver to ask
 * @param domain The domain to ask about
 * @param subdomain The subdomain to ask about
 * @returns The address stored at subdomain.domain
 */
async function resolveENS(resolver : PublicResolver, domain : string, subdomain : string) : Promise<string> {
    return await resolver["addr(bytes32)"](ethers.utils.keccak256(
        ethers.utils.defaultAbiCoder.encode(
            ["bytes32 node", "bytes32 _label"], 
            [toEnsNode(domain), toEnsLabel(subdomain)]
        )));
}

export { toEnsNode, toEnsLabel, resolveENS };
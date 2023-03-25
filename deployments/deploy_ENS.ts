// Framework
import { ethers } from "hardhat";

// Utils
import { toEnsLabel } from "../utils/ensHelper";

// Types
import { ENSRegistry } from "../typechain-types";

// Other

// Insipration:  https://docs.ens.domains/deploying-ens-on-a-private-chain

/**
 * Deployes the ENSRegistry
 * @returns The newly deployed ENSRegistry contract
 */
async function deployENS() {
    const ENSRegistry = await ethers.getContractFactory("ENSRegistry");
    const ens = await ENSRegistry.deploy();
    console.log(`Ens registry deployed at ${ens.address}`);
    return ens;
};

/**
 * Deployes a PublicResolver for the given subdomain
 * @param ens The ENSRegistry to register the subdomain with
 * @param owner The address of the owner of the subdomain
 * @param subdomain The subdomain in string form
 * @returns The newly deployed PublicResolver contract
 */
async function deployResolver(ens : ENSRegistry, owner : string, subdomain : string) {
    const PublicResolver = await ethers.getContractFactory("PublicResolver");
    const resolver = await PublicResolver.deploy(ens.address, ethers.constants.AddressZero, owner, owner);
    const resolverNode = ethers.constants.HashZero;
    const resolverLabel = toEnsLabel(subdomain);
    await ens.setSubnodeRecord(
        resolverNode,
        resolverLabel,
        owner,
        resolver.address,
        0
    );
    console.log(`Ens resolver deployed for subdomain ${subdomain} at ${resolver.address}`);
    return resolver;
}

export { deployENS, deployResolver }
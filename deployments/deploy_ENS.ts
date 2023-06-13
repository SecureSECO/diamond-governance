/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  *
  * This source code is licensed under the MIT license found in the
  * LICENSE file in the root directory of this source tree.
  */

// Framework
import { ethers } from "hardhat";

// Utils
import { toEnsLabel } from "../utils/ensHelper";

// Types
import { ENSRegistry } from "../typechain-types";

// Other

/// This deployer deploys ENS, so it can be deployed to any network (including hardhats network for testing).
/// Insipration:  https://docs.ens.domains/deploying-ens-on-a-private-chain

/**
 * Deployes the ENSRegistry
 * @returns The newly deployed ENSRegistry contract
 */
async function deployENS() {
    const ENSRegistry = await ethers.getContractFactory("ENSRegistry");
    const ens = await ENSRegistry.deploy();
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
    return resolver;
}

export { deployENS, deployResolver }
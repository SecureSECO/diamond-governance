/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  *
  * This source code is licensed under the MIT license found in the
  * LICENSE file in the root directory of this source tree.
  */

import { ethers } from "hardhat";
import { deployAragonFrameworkWithEns } from "../../deployments/deploy_AragonOSxFramework";
import { deployDiamondGovernance } from "../../deployments/deploy_DiamondGovernance";
import { DiamondCut, createDiamondGovernanceRepo, DAOCreationSettings, CreateDAO } from "../../utils/diamondGovernanceHelper";
import { setDeployedENS, setDeployedAragon, setDeployedDiamondGovernance, setDiamondGovernanceRepo, getDeployedDiamondGovernance } from "../../utils/deployedContracts";
import { DiamondGovernanceClient } from "../../sdk/index";
import { customIpfsAdd, customIpfsGet } from "../../utils/ipfsHelper";

const ipfs : any[] = [];

export async function deployTestNetwork() {
    const [owner] = await ethers.getSigners();
    const { ensFramework, aragonOSxFramework } = await deployAragonFrameworkWithEns();
    const diamondGovernanceFramework = await deployDiamondGovernance();
    setDeployedENS(ensFramework);
    setDeployedAragon(aragonOSxFramework);
    setDeployedDiamondGovernance(diamondGovernanceFramework, owner);
    setDiamondGovernanceRepo(await createDiamondGovernanceRepo("diamondgovernance", owner));
    customIpfsAdd(async (json) => { return (ipfs.push(JSON.parse(json)) - 1).toString(); });
    customIpfsGet(async (hash) => { return ipfs[Number(hash)]; })
}

export async function defaultDiamondCut(diamondGovernance : any) : Promise<DiamondCut[]> {
  return [
    await DiamondCut.All(diamondGovernance.DiamondCutFacet),
    await DiamondCut.All(diamondGovernance.DiamondLoupeFacet),
    await DiamondCut.All(diamondGovernance.DAOReferenceFacet),
    await DiamondCut.All(diamondGovernance.PluginFacet),
    await DiamondCut.All(diamondGovernance.AlwaysAcceptAuthFacet)
  ];
}

export async function createTestingDao(diamondCut : DiamondCut[], addDefault : boolean = true) : Promise<DiamondGovernanceClient> {
  const [owner] = await ethers.getSigners();
  const diamondGovernance = await getDeployedDiamondGovernance(owner);
  const cut : DiamondCut[] = diamondCut.concat(addDefault ? await defaultDiamondCut(diamondGovernance) : []);
  const settings : DAOCreationSettings = {
    trustedForwarder: ethers.constants.AddressZero,
    daoURI: "https://plopmenz.com",
    subdomain: "mydao",
    metadata: {
      name: "Name",
      description: "Description",
      links: [],
      avatar: "Avatar"
    },
    diamondCut: cut,
    additionalPlugins: []
  };
  const dao = await CreateDAO(settings, owner);
  return new DiamondGovernanceClient(dao.diamondGovernance.address, owner);
}
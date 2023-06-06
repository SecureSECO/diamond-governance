/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  *
  * This source code is licensed under the MIT license found in the
  * LICENSE file in the root directory of this source tree.
  */

// Framework
import { ethers } from "hardhat";

// Tests
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";

// Utils
import { getDeployedDiamondGovernance } from "../utils/deployedContracts";
import { createTestingDao, deployTestNetwork } from "./utils/testDeployer";
import { DiamondCut } from "../utils/diamondGovernanceHelper";
import { ABCDeployer, ABCDeployerSettings } from "../deployments/deploy_MonetaryToken";
import { wei } from "../utils/etherUnits";

// Types

// Other


async function getClient() {
  await loadFixture(deployTestNetwork);
  const [owner] = await ethers.getSigners();
  const ABCDeployerSettings : ABCDeployerSettings = {
    curveParameters: {
      theta: 0,
      friction: 0,
      reserveRatio: 0,
    },
    hatchParameters: {
      initialPrice: wei.mul(0),
      minimumRaise: wei.mul(0),
      maximumRaise: wei.mul(0),
      hatchDeadline: 0,
    },
    vestingSchedule: {
      cliff: 0,
      start: 0,
      duration: 0,
      slicePeriodSeconds: 1,
      revocable: false,
    },
  };
  const deployer = new ABCDeployer(ABCDeployerSettings);
  const monetaryToken = await deployer.beforeDAODeploy();
  const diamondGovernance = await getDeployedDiamondGovernance(owner);
  const MonetaryTokenFacetSettings = {
    monetaryTokenContractAddress: monetaryToken,
  };
  const ABCConfigureFacetSettings = {
    marketMaker: deployer.deployedContracts.MarketMaker,
  };
  const cut : DiamondCut[] = [
      await DiamondCut.All(diamondGovernance.MonetaryTokenFacet, [MonetaryTokenFacetSettings]),
      await DiamondCut.All(diamondGovernance.ABCConfigureFacet, [ABCConfigureFacetSettings]),
  ];
  const client = await createTestingDao(cut);
  const IDAOReferenceFacet = await client.pure.IDAOReferenceFacet();
  await deployer.afterDAODeploy(await IDAOReferenceFacet.dao(), client.pure.pluginAddress);
  return client;
}

describe("ABC", () => {
  it("should update contract address on set", async () => {
    const client = await loadFixture(getClient);
    
    const IChangeableTokenContract = await client.pure.IChangeableTokenContract();
    console.log(await IChangeableTokenContract.getTokenContractAddress());

    const IABCConfigureFacet = await client.pure.IABCConfigureFacet();
    console.log(await IABCConfigureFacet.getMarketMaker());
  });
});
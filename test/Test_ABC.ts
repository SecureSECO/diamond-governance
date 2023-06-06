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
import { expect } from "chai";
import { loadFixture, time } from "@nomicfoundation/hardhat-network-helpers";

// Utils
import { getDeployedDiamondGovernance } from "../utils/deployedContracts";
import { createTestingDao, deployTestNetwork } from "./utils/testDeployer";
import { DiamondCut } from "../utils/diamondGovernanceHelper";
import { ether, wei } from "../utils/etherUnits";
import { minutes, now } from "../utils/timeUnits";
import { GetTypedContractAt } from "../utils/contractHelper";

// Types
import { ERC20, SimpleHatch } from "../typechain-types";

// Other
import { ABCDeployer, ABCDeployerSettings } from "../deployments/deploy_MonetaryToken";

async function getClient() {
  await loadFixture(deployTestNetwork);
  const [owner] = await ethers.getSigners();
  // Use fixed supply monetary token as external token
  const ERC20MonetaryTokenContract = await ethers.getContractFactory("ERC20MonetaryToken");
  const ERC20MonetaryToken = await ERC20MonetaryTokenContract.deploy("Token", "TOK");
  await ERC20MonetaryToken.init(owner.address, ether.mul(1_000_000));

  const ABCDeployerSettings : ABCDeployerSettings = {
    curveParameters: {
      theta: 1,
      friction: 2,
      reserveRatio: 3,
    },
    hatchParameters: {
      initialPrice: wei.mul(1),
      minimumRaise: wei.mul(10),
      maximumRaise: wei.mul(20),
      hatchDeadline: now() + 10 * minutes,
    },
    vestingSchedule: {
      cliff: 5 * minutes,
      start: now() + 10 * minutes,
      duration: 15 * minutes,
      slicePeriodSeconds: 1,
      revocable: false,
    },
    externalERC20: ERC20MonetaryToken.address,
  };
  const deployer = new ABCDeployer(ABCDeployerSettings);
  const monetaryToken = await deployer.beforeDAODeploy();
  const diamondGovernance = await getDeployedDiamondGovernance(owner);
  const MonetaryTokenFacetSettings = {
    monetaryTokenContractAddress: monetaryToken,
  };
  const ABCConfigureFacetSettings = {
    marketMaker: deployer.deployedContracts.MarketMaker,
    hatcher: deployer.deployedContracts.SimpleHatch,
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
  describe("Hatching", () => {
    it("should not be able to hatch right away", async () => {
      const client = await loadFixture(getClient);
      const [owner] = await ethers.getSigners();
  
      const IABCConfigureFacet = await client.pure.IABCConfigureFacet();
      const SimpleHatch = await GetTypedContractAt<SimpleHatch>("SimpleHatch", await IABCConfigureFacet.getHatcher(), owner);
      expect(SimpleHatch.hatch()).to.be.revertedWithCustomError(SimpleHatch, "NotEnoughRaised");
    });

    it("should not be able to hatch right away", async () => {
      const client = await loadFixture(getClient);
      const [owner] = await ethers.getSigners();
  
      const IABCConfigureFacet = await client.pure.IABCConfigureFacet();
      const SimpleHatch = await GetTypedContractAt<SimpleHatch>("SimpleHatch", await IABCConfigureFacet.getHatcher(), owner);
      expect(SimpleHatch.hatch()).to.be.revertedWithCustomError(SimpleHatch, "NotEnoughRaised");
    });
  
    it("should not be able to hatch right away after hitting the minimum raise", async () => {
      const client = await loadFixture(getClient);
      const [owner] = await ethers.getSigners();
  
      const IABCConfigureFacet = await client.pure.IABCConfigureFacet();
      const SimpleHatch = await GetTypedContractAt<SimpleHatch>("SimpleHatch", await IABCConfigureFacet.getHatcher(), owner);
      const externalToken = await GetTypedContractAt<ERC20>("ERC20", (await SimpleHatch.getState()).params.externalToken, owner);
      await externalToken.approve(SimpleHatch.address, 10);
      await SimpleHatch.contribute(10);
      expect(SimpleHatch.hatch()).to.be.revertedWithCustomError(SimpleHatch, "NotEnoughRaised");
    });
    
    it("should be able to hatch after hitting the minimum raise and reaching the hatch deadline", async () => {
      const client = await loadFixture(getClient);
      const [owner] = await ethers.getSigners();
  
      const IABCConfigureFacet = await client.pure.IABCConfigureFacet();
      const SimpleHatch = await GetTypedContractAt<SimpleHatch>("SimpleHatch", await IABCConfigureFacet.getHatcher(), owner);
      const externalToken = await GetTypedContractAt<ERC20>("ERC20", (await SimpleHatch.getState()).params.externalToken, owner);
      await externalToken.approve(SimpleHatch.address, 10);
      await SimpleHatch.contribute(10);
      await time.increase(5 * minutes);
      expect(SimpleHatch.hatch()).to.not.be.reverted;
    });
    
    it("should be able to hatch after hitting the maximum raise, even before the hatch deadline", async () => {
      const client = await loadFixture(getClient);
      const [owner] = await ethers.getSigners();
  
      const IABCConfigureFacet = await client.pure.IABCConfigureFacet();
      const SimpleHatch = await GetTypedContractAt<SimpleHatch>("SimpleHatch", await IABCConfigureFacet.getHatcher(), owner);
      const externalToken = await GetTypedContractAt<ERC20>("ERC20", (await SimpleHatch.getState()).params.externalToken, owner);
      await externalToken.approve(SimpleHatch.address, 20);
      await SimpleHatch.contribute(20);
      expect(SimpleHatch.hatch()).to.not.be.reverted;
    });
  });
});
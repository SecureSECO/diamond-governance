/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  *
  * This source code is licensed under the MIT license found in the
  * LICENSE file in the root directory of this source tree.
  */

// Framework
import { ethers } from "hardhat";
import { BigNumber } from "ethers";

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
import { ERC20, MarketMaker, SimpleHatch, Vesting } from "../typechain-types";

// Other
import { ABCDeployer, ABCDeployerSettings } from "../deployments/deploy_MonetaryToken";
import { DiamondGovernanceClient } from "../sdk/index";

const hatchParameters = {
  initialPrice: ether.mul(1),
  minimumRaise: ether.mul(10),
  maximumRaise: ether.mul(20),
  hatchDeadlineTime: now() + 10 * minutes,
};
const vestingSchedule = { 
  cliff: 5 * minutes,
  duration: 15 * minutes,
};

async function getClient() {
  await loadFixture(deployTestNetwork);
  const [owner] = await ethers.getSigners();
  // Use fixed supply monetary token as external token
  const ERC20MonetaryTokenContract = await ethers.getContractFactory("ERC20MonetaryToken");
  const ERC20MonetaryToken = await ERC20MonetaryTokenContract.deploy("Token", "TOK");
  await ERC20MonetaryToken.init(owner.address, ether.mul(1_000_000));

  const ABCDeployerSettings : ABCDeployerSettings = {
    curveParameters: {
      theta: 0.05 * 10**6,
      friction: 0.01 * 10**6,
      reserveRatio: 0.2 * 10**6,
    },
    hatchParameters: {
      initialPrice: hatchParameters.initialPrice,
      minimumRaise: hatchParameters.minimumRaise,
      maximumRaise: hatchParameters.maximumRaise,
      hatchDeadline: now() + hatchParameters.hatchDeadlineTime,
    },
    vestingSchedule: {
      cliff: vestingSchedule.cliff,
      start: now() + hatchParameters.hatchDeadlineTime,
      duration: vestingSchedule.duration,
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

async function Contribute(client : DiamondGovernanceClient, amount : BigNumber) {
  const [owner] = await ethers.getSigners();
  const IABCConfigureFacet = await client.pure.IABCConfigureFacet();
  const SimpleHatch = await GetTypedContractAt<SimpleHatch>("SimpleHatch", await IABCConfigureFacet.getHatcher(), owner);
  const externalToken = await GetTypedContractAt<ERC20>("ERC20", (await SimpleHatch.getState()).params.externalToken, owner);
  await externalToken.approve(SimpleHatch.address, amount);
  await SimpleHatch.contribute(amount);
  return SimpleHatch;
}

async function GetVesting() {
  const client = await loadFixture(getClient);
  const [owner] = await ethers.getSigners();
  const SimpleHatch = await Contribute(client, hatchParameters.maximumRaise);
  await SimpleHatch.hatch();

  await SimpleHatch.claimVesting();
  return GetTypedContractAt<Vesting>("Vesting", await SimpleHatch.viewVesting(), owner);
}

async function GetMarketMaker() {
  const client = await loadFixture(getClient);
  const [owner] = await ethers.getSigners();
  const SimpleHatch = await Contribute(client, hatchParameters.maximumRaise);
  await SimpleHatch.hatch();

  const IABCConfigureFacet = await client.pure.IABCConfigureFacet();
  const MarketMakerAddress = await IABCConfigureFacet.getMarketMaker();
  const externalToken = await GetTypedContractAt<ERC20>("ERC20", (await SimpleHatch.getState()).params.externalToken, owner);
  await externalToken.approve(MarketMakerAddress, ethers.constants.MaxUint256);

  return GetTypedContractAt<MarketMaker>("MarketMaker", MarketMakerAddress, owner);
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

    it("should not be able to hatch if under minimum raise and after the deadline", async () => {
      const client = await loadFixture(getClient);
      const [owner] = await ethers.getSigners();
  
      const IABCConfigureFacet = await client.pure.IABCConfigureFacet();
      const SimpleHatch = await GetTypedContractAt<SimpleHatch>("SimpleHatch", await IABCConfigureFacet.getHatcher(), owner);
      await time.increase(hatchParameters.hatchDeadlineTime);
      expect(SimpleHatch.hatch()).to.be.revertedWithCustomError(SimpleHatch, "NotEnoughRaised");
    });
  
    it("should not be able to hatch right away if at the minimum raise", async () => {
      const client = await loadFixture(getClient);
  
      const SimpleHatch = await Contribute(client, hatchParameters.minimumRaise);

      expect(SimpleHatch.hatch()).to.be.revertedWithCustomError(SimpleHatch, "NotEnoughRaised");
    });
    
    it("should be able to hatch if at the minimum raise and after the hatch deadline", async () => {
      const client = await loadFixture(getClient);

      const SimpleHatch = await Contribute(client, hatchParameters.minimumRaise);
      await time.increase(hatchParameters.hatchDeadlineTime);

      expect(SimpleHatch.hatch()).to.not.be.reverted;
    });
    
    it("should be able to hatch right away if at the maximum raise", async () => {
      const client = await loadFixture(getClient);
      
      const SimpleHatch = await Contribute(client, hatchParameters.maximumRaise);

      expect(SimpleHatch.hatch()).to.not.be.reverted;
    });
  });

  describe("Vesting", () => {
    it("should allow contributors to claim their vesting contract", async () => {
      const client = await loadFixture(getClient);
  
      const SimpleHatch = await Contribute(client, hatchParameters.maximumRaise);
      await SimpleHatch.hatch();
      await SimpleHatch.claimVesting();
      
      expect(await SimpleHatch.viewVesting()).to.not.be.equal(ethers.constants.AddressZero);
    });

    it("should not allow non-contributors to claim a vesting contract", async () => {
      const client = await loadFixture(getClient);
      const [_, nonContributor] = await ethers.getSigners();
  
      const SimpleHatch = await Contribute(client, hatchParameters.maximumRaise);
      await SimpleHatch.hatch();
      const SimpleHatchNonContributor = await GetTypedContractAt<SimpleHatch>("SimpleHatch", SimpleHatch.address, nonContributor);
      
      expect(SimpleHatchNonContributor.claimVesting()).to.be.revertedWithCustomError(SimpleHatch, "NoContribution");
    });

    it("should allow all tokens to be claimable after vesting is over", async () => {
      const vesting = await loadFixture(GetVesting);

      const vestingState = await vesting.getState();
      await time.increaseTo(vestingState.schedule.start.add(vestingState.schedule.duration));

      expect(await vesting.computeReleasableAmount()).to.be.equal(vestingState.amountTotal);
    });

    it("should allow half of the tokens to be claimable halfway through the vesting", async () => {
      const vesting = await loadFixture(GetVesting);

      const vestingState = await vesting.getState();
      await time.increaseTo(vestingState.schedule.start.add(vestingState.schedule.duration.div(2)));

      expect(await vesting.computeReleasableAmount()).to.be.equal(vestingState.amountTotal.div(2));
    });

    it("should not allow any tokens to be claimable before the cliff", async () => {
      const vesting = await loadFixture(GetVesting);

      const vestingState = await vesting.getState();
      await time.increaseTo(vestingState.schedule.start.add(vestingState.schedule.cliff.sub(1)));

      expect(await vesting.computeReleasableAmount()).to.be.equal(0);
    });

    it("should release the releaseable tokens", async () => {
      const vesting = await loadFixture(GetVesting);
      const [owner] = await ethers.getSigners();

      await time.increase(vestingSchedule.duration);
      const releaseable = await vesting.computeReleasableAmount();
      const ERC20 = await GetTypedContractAt<ERC20>("ERC20", await vesting.getToken(), owner);

      const balanceBefore = await ERC20.balanceOf(owner.address);
      await vesting.release(releaseable);

      expect(await ERC20.balanceOf(owner.address)).to.be.equal(balanceBefore.add(releaseable));
    });

    it("should not release more than the total amount", async () => {
      const vesting = await loadFixture(GetVesting);
      const [owner] = await ethers.getSigners();

      const ERC20 = await GetTypedContractAt<ERC20>("ERC20", await vesting.getToken(), owner);
      const balanceBefore = await ERC20.balanceOf(owner.address);
      const total = (await vesting.getState()).amountTotal;

      await time.increase(vestingSchedule.duration / 2);
      await vesting.release(await vesting.computeReleasableAmount());
      await time.increase(vestingSchedule.duration / 2);
      await vesting.release(await vesting.computeReleasableAmount());
      await time.increase(vestingSchedule.duration / 2);
      await vesting.release(await vesting.computeReleasableAmount());

      expect(await ERC20.balanceOf(owner.address)).to.be.equal(balanceBefore.add(total));
    });
  });

  describe("MarketMaker", () => {
    it("should not allow to mint before hatch", async () => {
      const client = await loadFixture(getClient);
      const [owner] = await ethers.getSigners();
  
      const IABCConfigureFacet = await client.pure.IABCConfigureFacet();
      const MarketMaker = await GetTypedContractAt<MarketMaker>("MarketMaker", await IABCConfigureFacet.getMarketMaker(), owner);
      const externalToken = await GetTypedContractAt<ERC20>("ERC20", await MarketMaker.externalToken(), owner);
      await externalToken.approve(MarketMaker.address, ethers.constants.MaxUint256);
      
      expect(MarketMaker.mint(ether.mul(1), wei.mul(0))).to.be.revertedWithCustomError(MarketMaker, "HatchingNotStarted");
    });

    it("should give the correct amount of bonded tokens on mint", async () => {
      const MarketMaker = await loadFixture(GetMarketMaker);
      const [owner] = await ethers.getSigners();
      const amount = ether.mul(1);

      const bondedToken = await GetTypedContractAt<ERC20>("ERC20", await MarketMaker.bondedToken(), owner);
      const balanceBefore = await bondedToken.balanceOf(owner.address);
      const expectedTokens = await MarketMaker.calculateMint(amount);
      await MarketMaker.mint(amount, wei.mul(0));

      expect(await bondedToken.balanceOf(owner.address)).to.be.equal(balanceBefore.add(expectedTokens));
    });

    it("should take the correct amount of external tokens on mint", async () => {
      const MarketMaker = await loadFixture(GetMarketMaker);
      const [owner] = await ethers.getSigners();
      const amount = ether.mul(1);

      const externalToken = await GetTypedContractAt<ERC20>("ERC20", await MarketMaker.externalToken(), owner);
      const balanceBefore = await externalToken.balanceOf(owner.address);
      await MarketMaker.mint(amount, wei.mul(0));

      expect(await externalToken.balanceOf(owner.address)).to.be.equal(balanceBefore.sub(amount));
    });
    
    it("should send some of the external token to the DAO on mint", async () => {
      const client = await loadFixture(getClient);
      const MarketMaker = await loadFixture(GetMarketMaker);
      const [owner] = await ethers.getSigners();
      const amount = ether.mul(1);

      const IDAOReferenceFacet = await client.pure.IDAOReferenceFacet();
      const DAOAddress = await IDAOReferenceFacet.dao();
      const externalToken = await GetTypedContractAt<ERC20>("ERC20", await MarketMaker.externalToken(), owner);
      const balanceBefore = await externalToken.balanceOf(DAOAddress);
      await MarketMaker.mint(amount, wei.mul(0));

      expect(await externalToken.balanceOf(DAOAddress)).to.be.gt(balanceBefore);
    });

    it("should give the correct amount of external tokens on burn", async () => {
      const MarketMaker = await loadFixture(GetMarketMaker);
      const [owner] = await ethers.getSigners();
      const mintAmount = ether.mul(1);

      await MarketMaker.mint(mintAmount, wei.mul(0));
      const bondedToken = await GetTypedContractAt<ERC20>("ERC20", await MarketMaker.bondedToken(), owner);
      const externalToken = await GetTypedContractAt<ERC20>("ERC20", await MarketMaker.externalToken(), owner);
      const bondedTokenBalance = await bondedToken.balanceOf(owner.address);
      const balanceBefore = await externalToken.balanceOf(owner.address);
      let expectedTokens = await MarketMaker.calculateBurn(bondedTokenBalance);
      expectedTokens = expectedTokens.sub(await MarketMaker.calculateFee(expectedTokens));
      await MarketMaker.burn(bondedTokenBalance, wei.mul(0));

      expect(await externalToken.balanceOf(owner.address)).to.be.equal(balanceBefore.add(expectedTokens));
      expect(expectedTokens).to.be.lt(mintAmount);
    });

    it("should take the correct amount of bonded tokens on burn", async () => {
      const MarketMaker = await loadFixture(GetMarketMaker);
      const [owner] = await ethers.getSigners();
      const mintAmount = ether.mul(1);

      await MarketMaker.mint(mintAmount, wei.mul(0));
      const bondedToken = await GetTypedContractAt<ERC20>("ERC20", await MarketMaker.bondedToken(), owner);
      const bondedTokenBalance = await bondedToken.balanceOf(owner.address);
      let expectedTokens = await MarketMaker.calculateBurn(bondedTokenBalance);
      expectedTokens = expectedTokens.sub(await MarketMaker.calculateFee(expectedTokens));
      await MarketMaker.burn(bondedTokenBalance, wei.mul(0));

      expect(await bondedToken.balanceOf(owner.address)).to.be.equal(0);
    });

    it("should revert if receiving less bonded tokens on mint than min recieve", async () => {
      const MarketMaker = await loadFixture(GetMarketMaker);
      const amount = ether.mul(1);

      const expectedTokens = await MarketMaker.calculateMint(amount);

      expect(MarketMaker.mint(amount, expectedTokens.add(1))).to.be.revertedWithCustomError(MarketMaker, "WouldRecieveLessThanMinRecieve");
    });

    it("should revert if receiving less bonded tokens on mint than min recieve", async () => {
      const MarketMaker = await loadFixture(GetMarketMaker);
      const amount = ether.mul(1);

      let expectedTokens = await MarketMaker.calculateBurn(amount);
      expectedTokens = expectedTokens.sub(await MarketMaker.calculateFee(expectedTokens));

      expect(MarketMaker.burn(amount, expectedTokens.add(1))).to.be.revertedWithCustomError(MarketMaker, "WouldRecieveLessThanMinRecieve");
    });

    it.only("should give you less tokens on burn than what you paid to mint", async () => {
      const MarketMaker = await loadFixture(GetMarketMaker);
      const [owner] = await ethers.getSigners();
      const mintAmount = ether.mul(1);

      const externalERC20 = await GetTypedContractAt<ERC20>("ERC20", await MarketMaker.externalToken(), owner);
      const balanceBefore = await externalERC20.balanceOf(owner.address);
      await MarketMaker.mint(mintAmount, wei.mul(0));
      const bondedToken = await GetTypedContractAt<ERC20>("ERC20", await MarketMaker.bondedToken(), owner);
      const bondedTokenBalance = await bondedToken.balanceOf(owner.address);
      await MarketMaker.burn(bondedTokenBalance, wei.mul(0));

      expect(await externalERC20.balanceOf(owner.address)).to.be.lt(balanceBefore);
    });
  });
});
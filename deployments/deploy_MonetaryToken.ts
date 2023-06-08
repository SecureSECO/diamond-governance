/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  *
  * This source code is licensed under the MIT license found in the
  * LICENSE file in the root directory of this source tree.
  */

// Framework
import hre from "hardhat";
import { ethers } from "hardhat";
import { BigNumber } from "ethers";
import { GetTypedContractAt } from "../utils/contractHelper";
import { ERC20MonetaryToken, ERC20BondedToken, MarketMaker, SimpleHatch } from "../typechain-types";
import { ether } from "../utils/etherUnits";
import { CurveParametersStruct } from "../typechain-types/contracts/facets/token/ERC20/monetary-token/ABC/core/MarketMaker";
import { HatchParametersStruct, VestingScheduleStruct } from "../typechain-types/contracts/facets/token/ERC20/monetary-token/ABC/core/SimpleHatch";

// Utils

// Types

// Other


export enum MonetaryTokenType { FixedSupply, ABC }

export abstract class MonetaryTokenDeployer {
  public runVerification : boolean = false;
  public deployedContracts : { [contractName : string] : string } = { };

  public abstract beforeDAODeploy() : Promise<string>;

  public abstract afterDAODeploy(dao : string, diamondGovernance : string) : Promise<void>;
}

export class FixedSupplyDeployer extends MonetaryTokenDeployer {
  public override async beforeDAODeploy() : Promise<string> {
    const ERC20MonetaryTokenContract = await ethers.getContractFactory("ERC20MonetaryToken");
    const ERC20MonetaryToken = await ERC20MonetaryTokenContract.deploy("SecureSECO Coin", "SECOIN");
    await ERC20MonetaryToken.deployed();
  
    if (this.runVerification) {
      try {
        console.log("Starting verification");
        // Wait for etherscan to process the deployment
        await new Promise(f => setTimeout(f, 10 * 1000));
        await hre.run("verify:verify", {
          address: ERC20MonetaryToken.address,
          constructorArguments: ["SecureSECO Coin", "SECOIN"],
        });
      } catch { }
    }
  
    this.deployedContracts.ERC20MonetaryToken = ERC20MonetaryToken.address;
    return ERC20MonetaryToken.address;
  }

  public override async afterDAODeploy(dao : string, diamondGovernance : string) : Promise<void> {
    const [owner] = await ethers.getSigners();
    const ERC20MonetaryToken = await GetTypedContractAt<ERC20MonetaryToken>("ERC20MonetaryToken", this.deployedContracts.ERC20MonetaryToken, owner);
    ERC20MonetaryToken.init(dao, ether.mul(1000000));
  }
}

export interface ABCDeployerSettings {
  curveParameters: {
    theta: number,
    friction: number,
    reserveRatio: number,
  },
  hatchParameters: {
    initialPrice: BigNumber,
    minimumRaise: BigNumber,
    maximumRaise: BigNumber,
    hatchDeadline: number,
  },
  vestingSchedule: {
    cliff: number,
    start: number,
    duration: number,
    revocable: boolean,
  },
  externalERC20: string,
} 

export class ABCDeployer extends MonetaryTokenDeployer {
  public settings : ABCDeployerSettings;

  constructor(_settings : ABCDeployerSettings) {
    super();

    this.settings = _settings;
  }

  public override async beforeDAODeploy() : Promise<string> {
    const ERC20BondedTokenContract = await ethers.getContractFactory("ERC20BondedToken");
    const ERC20BondedToken = await ERC20BondedTokenContract.deploy("SecureSECO Coin", "SECOIN");
    await ERC20BondedToken.deployed();
  
    if (this.runVerification) {
      try {
        console.log("Starting verification ERC20BondedToken");
        // Wait for etherscan to process the deployment
        await new Promise(f => setTimeout(f, 10 * 1000));
        await hre.run("verify:verify", {
          address: ERC20BondedToken.address,
          constructorArguments: ["SecureSECO Coin", "SECOIN"],
        });
      } catch { }
    }

    const BancorBondingCurveContract = await ethers.getContractFactory("BancorBondingCurve");
    const BancorBondingCurve = await BancorBondingCurveContract.deploy();
    await BancorBondingCurve.deployed();
  
    
    if (this.runVerification) {
      try {
        console.log("Starting verification BancorBondingCurve");
        // Wait for etherscan to process the deployment
        await new Promise(f => setTimeout(f, 10 * 1000));
        await hre.run("verify:verify", {
          address: BancorBondingCurve.address,
          constructorArguments: [],
        });
      } catch { }
    }

    const curveParameters : CurveParametersStruct = {
      theta: this.settings.curveParameters.theta,
      friction: this.settings.curveParameters.friction,
      reserveRatio: this.settings.curveParameters.reserveRatio,
      formula: BancorBondingCurve.address
    };
    const MarketMakerContract = await ethers.getContractFactory("MarketMaker");
    const MarketMaker = await MarketMakerContract.deploy(ERC20BondedToken.address, this.settings.externalERC20, curveParameters);
    await MarketMaker.deployed();
  
    
    if (this.runVerification) {
      try {
        console.log("Starting verification MarketMaker");
        // Wait for etherscan to process the deployment
        await new Promise(f => setTimeout(f, 10 * 1000));
        await hre.run("verify:verify", {
          address: MarketMaker.address,
          constructorArguments: ["SecureSECO Coin", "SECOIN"],
        });
      } catch { }
    }

    const hatchParameters : HatchParametersStruct = {
      externalToken: this.settings.externalERC20,
      bondedToken: ERC20BondedToken.address,
      pool: MarketMaker.address,
      initialPrice: this.settings.hatchParameters.initialPrice,
      minimumRaise: this.settings.hatchParameters.minimumRaise,
      maximumRaise: this.settings.hatchParameters.maximumRaise,
      hatchDeadline: this.settings.hatchParameters.hatchDeadline,
    }

    const SimpleHatchContract = await ethers.getContractFactory("SimpleHatch");
    const SimpleHatch = await SimpleHatchContract.deploy(hatchParameters, this.settings.vestingSchedule);
    await SimpleHatch.deployed();
  
    
    if (this.runVerification) {
      try {
        console.log("Starting verification SimpleHatch");
        // Wait for etherscan to process the deployment
        await new Promise(f => setTimeout(f, 10 * 1000));
        await hre.run("verify:verify", {
          address: SimpleHatch.address,
          constructorArguments: [hatchParameters, this.settings.vestingSchedule],
        });
      } catch { }
    }

    await ERC20BondedToken.grantPermission(await ERC20BondedToken.MINT_PERMISSION_ID(), MarketMaker.address);
    await ERC20BondedToken.grantPermission(await ERC20BondedToken.BURN_PERMISSION_ID(), MarketMaker.address);
    await MarketMaker.grantPermission(await MarketMaker.HATCH_PERMISSION_ID(), SimpleHatch.address);
  
    this.deployedContracts.ERC20BondedToken = ERC20BondedToken.address;
    this.deployedContracts.MarketMaker = MarketMaker.address;
    this.deployedContracts.SimpleHatch = SimpleHatch.address;
    return ERC20BondedToken.address;
  }

  public override async afterDAODeploy(dao : string, diamondGovernance : string) : Promise<void> {
    const [owner] = await ethers.getSigners();

    const ERC20BondedToken = await GetTypedContractAt<ERC20BondedToken>("ERC20BondedToken", this.deployedContracts.ERC20BondedToken, owner);
    const MarketMaker = await GetTypedContractAt<MarketMaker>("MarketMaker", this.deployedContracts.MarketMaker, owner);
    const SimpleHatch = await GetTypedContractAt<SimpleHatch>("SimpleHatch", this.deployedContracts.SimpleHatch, owner);
    
    await MarketMaker.grantPermission(await MarketMaker.CONFIGURE_PERMISSION_ID(), diamondGovernance);
    
    await ERC20BondedToken.setDao(dao);
    await MarketMaker.setDao(dao);
    await SimpleHatch.setDao(dao);

    await ERC20BondedToken.transferOwnership(diamondGovernance);
    await MarketMaker.transferOwnership(diamondGovernance);
    await SimpleHatch.transferOwnership(diamondGovernance);
  }
}
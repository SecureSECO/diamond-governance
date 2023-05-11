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

// Types
import {MonetaryToken} from "../typechain-types";

// Other

export const deployMonetaryTokenContract = async () : Promise<MonetaryToken> => {
  const MonetaryTokenContract = await ethers.getContractFactory("ERC20MonetaryToken");
  const MonetaryToken = await MonetaryTokenContract.deploy("SecureSECOCoin", "SECOIN");
  console.log(`Monetary token contract deployed at ${MonetaryToken.address}`);

  return MonetaryToken;
}
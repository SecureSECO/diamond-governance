/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  *
  * This source code is licensed under the MIT license found in the
  * LICENSE file in the root directory of this source tree.
  */

// Various ether units per Solidity spec
import { BigNumber } from "ethers";

export const wei = BigNumber.from(1);
export const gwei = BigNumber.from(10).pow(9);
export const ether = BigNumber.from(10).pow(18);
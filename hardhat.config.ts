/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  *
  * This source code is licensed under the MIT license found in the
  * LICENSE file in the root directory of this source tree.
  */

import "@nomicfoundation/hardhat-toolbox";
import '@openzeppelin/hardhat-upgrades';

// Typescript support for smart contract interaction
import '@typechain/hardhat'
import '@nomiclabs/hardhat-ethers'

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.17",
  networks: {
    hardhat: {
      accounts: {
        mnemonic: "lonely initial gold insect blue path episode kingdom fame execute ranch velvet",
        path: "m/44'/60'/0'/0",
        initialIndex: 0,
        count: 20,
        passphrase: "",
      },
    },
  },
};

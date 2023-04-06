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

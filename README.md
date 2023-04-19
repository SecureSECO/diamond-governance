# Diamond Governance
Diamond Governance is a very flexible plugin for AragonOSx. It acts as a bridge between the Aragon framework and ERC-2535 facets (https://eips.ethereum.org/EIPS/eip-2535). Multiple facets to customize the plugin are included in the project.  

# Setup
## Dependencies
NodeJS (>=14.x.x)  
npm (>=6.x.x)  

## Build process
npm i  
npm run compile  

## Secrets
Copy the .env.example file to a file called .env (located in the same folder). In this file you are required to add the secrets for any of the features you would like to use (MUMBAI_PRIVATE_KEY if you would like to deploy to mumbai for example).

# Commands available
## npm run compile
Compiles all the smart contracts and generates the typescript types.  

## npm run deploy
Deploys the plugin to the mumbai network. Currently this also creates a DAO with the Diamond Governance plugin.  
If the user would like to deploy to a different network they can use the command `npx hardhat run deployments/deploy.ts --network x` instead, where x is the name of the network, such as polygon, mainnet, sepolia etc.

## npm test
Runs the unit tests.  

## npm generate-sdk
Generates the sdk with the latest interfaces defined in contracts/utils/IntefaceIds.sol.  
To publish to npm (`npm i -g typescript` needed to be run once before):
```
cd sdk
npm version patch / npm version minor / npm version major
tsc --declaration
npm publish
```

### License

The majority of the code is [MIT licensed](./LICENSE). However, there are some files that have been taken and modified from an [AGPL-3.0 licensed](https://www.gnu.org/licenses/agpl-3.0.en.html) project ([aragon/osx](https://github.com/aragon/osx)). The specific license of a file can be found at the very first lines of the file.

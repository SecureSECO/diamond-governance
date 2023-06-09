<p align="center">
  <a
    href="https://github.com/SecureSECODAO/diamond-governance/blob/master/LICENSE"
    alt="License"
  >
    <img src="https://img.shields.io/github/license/SecureSECODAO/diamond-governance" />
  </a>
  <a
    href="https://github.com/SecureSECODAO/diamond-governance/graphs/contributors"
    alt="Contributors"
  >
    <img src="https://img.shields.io/github/contributors/SecureSECODAO/diamond-governance" />
  </a>
  <a
    href="https://github.com/SecureSECODAO/diamond-governance/pulse"
    alt="Activity"
  >
    <img src="https://img.shields.io/github/commit-activity/m/SecureSECODAO/diamond-governance" />
  </a>
  <a
    href="https://github.com/SecureSECODAO/diamond-governance/actions"
    alt="Actions"
  >
    <img src="https://github.com/SecureSECODAO/diamond-governance/actions/workflows/unit-test-pipeline.yml/badge.svg?branch=main" />
  </a>
</p>

# Diamond Governance
Diamond Governance is a very flexible plugin for AragonOSx. It acts as a bridge between the Aragon framework and [ERC-2535 facets](https://eips.ethereum.org/EIPS/eip-2535). Multiple facets to customize the plugin are included in the project. Currently, the plugin is only available on Mumbai, but it will launch on Polygon before the end of June. 

# SDK
A typescript sdk is available for this plugin, allowing developers to easily communicate with the plugin in their projects. It can be found on [npm](https://www.npmjs.com/package/@plopmenz/diamond-governance-sdk?activeTab=readme).

# Facets
## Governance
### Partial Voting
This facet extends upon Aragon's token voting. Instead of wallets only being able to vote once with all their voting power, proposals can be configured to allow people to vote multiple times with a part of their voting power. This plugin also supports multiple proposal types and a cap on voting power for any single wallet. Partial voting is based on the idea that people do not have super strong opinions on all proposals and thus do not want to influence the vote massively.
#### Partial Burn Voting
This facet is partial voting, with the addition of all used voting power being burned. If the proposal voted on does not reach the participation threshold, the plugin can be configured to make the burned tokens refundable. Partial burn voting is a way to make sure people will only vote on proposals that they care about, with an amount of voting power based on how much they care.
#### Partial Burn Voting Proposals
This facet adds to the proposal creation of partial voting. Proposal creation will burn an amount of voting power of the proposer. The plugin can be configured to make the burned tokens refundable if the created proposal passes. Partial burn voting proposals is created to incentivize people to put effort and thought into their proposals and thus filter out ridiculous and low quality proposals.
### Structures
Multiple governance structures have been defined for plugins to interact with each other. These structures allow future facets to be compatible with all existing plugins using the implemented structure interface.
#### Membership
These structures are related to what wallets are considered members of the DAO and other member-related information, such as ranks.
##### Base
All these plugins are based on the [`IMembership`](https://github.com/aragon/osx/blob/develop/packages/contracts/src/core/plugin/membership/IMembership.sol) of Aragon.
##### Extended
This interface requires the implementer to be able to tell if a wallet is a member at a certain timestamp and be able to provide a list of wallets that have been members at some point. This information can be used to loop over all members at a given timestamp on chain.
##### Tiered
This interface also gives each member a tier instead of a yes/no value. These tiers can be used however wanted, for example, to give members who achieve a certain feat more permissions.
##### Whitelist
This interface can add a wallet to the whitelist. This is a special way for a wallet to become a member, although it does not meet the normal member requirements.
#### Voting Power
These structures are related to how much voting power a given wallet has and losing or gaining voting power.
##### Base
The base governance structure should be able to provide information about the total voting power at a given block number and the total voting power of a certain wallet at a given block number.
##### Mintable
This interface can mint voting power to a given wallet. This is done with a token id and/or amount, depending on what the voting token interface is (ERC20, ERC721, or ERC1155).
##### Burnable
This interface can burn voting power from a given wallet. This is just an amount, and the implementer should decide how this maps to token ids and amounts.
## Token
### ERC20
#### Governance ERC20
This token is identical to the Governance ERC20 contract made by Aragon, only converted to a facet.
##### Governance ERC20 Burnable
This facet is an extension of Governance ERC20, allowing the token to be burned.
##### Governance ERC20 Disabled
This facet is an alteration of Governance ERC20, allowing functionality to be disabled. This will most often be used to create non-transferable and/or non-delegatable tokens.
### ERC721 and ERC1155
These token types can be implemented the future. In all the code written so far, they have been kept in mind, so after implementation, they will be compatible with the existing facets.
#### Claiming
##### Time based
Allows time based rewards to be available to be claimed by members of the DAO. There is also a tiered version that allows members of different tiers to get different rewards. There is also a configurable maximum amount of claimable tokens at once, preventing inactive members from being able to claim a large sum of tokens after a long period of inactivity.
##### One time
Allows for a one-time reward to be claimed. The most basic claimable facet of this type will be claimable once per wallet, given that the wallet is a member of the DAO. There is a second, more advanced version that allows users to claim a reward for every verification that they pass.
#### Monetary ERC20
An option for a monetary token next to the governance token is provided. This allows a second way of rewarding people in the DAO. This token is stored in the DAO treasury, but it might require the DAO to approve the Diamond Governance to spend funds on its behalf for some functionality to work. Currently 2 options are provided for this monetary token, either a fixed supply that will mint all tokens on creation to the DAO treasury, or an augmented bonding curve.
## Variable growth
Linear, exponential and contrant growth multipliers are supported. This allows certain rewards or number to grow over time according to a certain variable. 
## Permissions
The permission management defines which wallets are allowed to do certain actions. 
### AragonOSx
Currently, this is the only permission provider using the grant functionality of the DAO. However, the implementation allows for more providers to be added easily in the future and also allows members to use their own custom permission provider if wanted.
## Other
### Verification
Diamond Governance is the plugin to implement [Secure SECO Verification](https://github.com/SecureSECODAO/SecureSECOVerification), allowing wallets to become members of the DAO by verifying with their 1-year-old GitHub account or proof of humanity.
### GitHub Pull Request Merger
Allows the plugin to merge pull requests on GitHub. This means that DAO members will be able to maintain the GitHub without needing to trust a centralized team of reviewers. This does however require some setup, which can be found on [their GitHub](https://github.com/SecureSECODAO/SecureSECOPullRequestMerger).


**This point onward is meant for developers of the projects; there will be no interesting information for regular users.**
# Setup
## Dependencies
NodeJS (>=14.x.x)  
npm (>=6.x.x)  

## Build process
```
npm i  
npm run compile  
```

## Secrets
Copy the [`.env.example`](./.env.example) file to a file called `.env` (located in the same folder). In this file you are required to add the secrets for any of the features you would like to use (`MUMBAI_PRIVATE_KEY` if you would like to deploy to Mumbai for example).

# Commands available
## npm run compile
Compiles all the smart contracts and generates the typescript types.  

## npm run deploy
Deploys the plugin to the Mumbai network. Currently, this also creates a DAO with the Diamond Governance plugin.  
If the user would like to deploy to a different network, they can use the command `npx hardhat run deployments/deploy.ts --network x` instead, where x is the name of the network, such as polygon, mainnet, sepolia etc.

## npm test
Runs the unit tests.  

## npm run generate-abis
Copies the abis from the hardhat artifacts to abis.json, this allows us to fetch contract using ethers based on name and thus eliminates the hardhat dependancy of the SDK. This command is run automatically everywhere it is needed.

## npm run generate-sdk
Generates the sdk with the latest interfaces defined in contracts/utils/IntefaceIds.sol.  
Publishing to npm is done automatically on creating a release on the GitHub repo.  

## npm run generate-facet --name --output --includeStorage
This command will generate a facet, interface and optionally a storage contract for you based on the naming schemes. In case you want to add a facet, it is highly recommended to use this approach for developer comfort and to prevent typos. Please do note that output directory is from contract/facets onwards, was facets should not be placed in different directories.

### Facet development
To learn more about facet development you can look into the [`FACET_DEV.md`](/FACET_DEV.md) file.

### License
The majority of the code is [MIT licensed](./LICENSE). However, there are some files that have been taken and modified from an [AGPL-3.0 licensed](https://www.gnu.org/licenses/agpl-3.0.en.html) project ([aragon/osx](https://github.com/aragon/osx)). The specific license of a file can be found at the very first lines of the file.

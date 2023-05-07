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
Diamond Governance is a very flexible plugin for AragonOSx. It acts as a bridge between the Aragon framework and [ERC-2535 facets](https://eips.ethereum.org/EIPS/eip-2535). Multiple facets to customize the plugin are included in the project. Currently the plugin is only launched on mumbai, but will launch on polygon before the end of June. A website to easily create a DAO with Diamond Governance and configure it to your usecase is planned, but not yet finished.

# Facets
## Governance
### Partial Voting
This facet extends upon Aragons token voting. Instead of wallets only being able to vote once with all their voting power, proposals can be configured to allow people to vote multiple times with a part of their voting power. This plugin also supports multiple proposal types and a cap on voting power by any single wallet. Partial voting is based on the idea that people do not have super strong opinions on all proposals and thus also dont want to influence the vote massively.
#### Partial Burn Voting
This facet is partial voting with the addition of all used voting power being burned. If the proposal voted on does not reach the participation threshold, the plugin can be configured for these tokens to be refundable. Partial burn voting is a way to make sure people will only vote on proposal that they care about with an amount of voting power based on how much they care.
#### Partial Burn Voting Proposals
This facet adds to the proposal creation of partial voting. Proposal creation will burn an amount of voting power of the proposer. The plugin can be configured for these tokens to be refundable if the created proposal passes. Partial burn voting proposals is created to incentivize people to put effort and thought into their proposal and thus filters out ridiculous and low quality proposals.
### Structures
Multiple governance structures have been defined for plugins to interact with each other. These structures allow future facets to be compatible with all existing plugins using the implementented structure interface.
#### Membership
These strucutres are related to what wallets are considered to be members of the DAO and other member related information, such as ranks.
##### Base
All these plugins are based on the IMembership of Aragon.
##### Extended
This interface requires the implementer to be able to tell if a wallet is a member at a certain timestamp and be able to provide a list of wallets that have been a member at some point. This information can be used to loop over all members at a given timestamp on chain.
##### Tiered
This interfaces also gives each member a tier instead of a yes/no value. These tiers can be used however wanted, for example to give members that achieved a certain feat more permissions.
##### Whitelist
This interfaces can add a wallet to the whitelist. This is a special way for a wallet to become a member although not meeting the normal member requirements.
#### Voting Power
These strucutres are related to how much voting power a given wallet has and losing/gaining voting power.
##### Base
The base governance structure should be able to provide information about the total voting power at a given block number and the total voting power of a certain wallet at a given block number.
##### Mintable
This interface can mint voting power to a given wallet. This is done with token id and/or amount, depending on what the voting token interface is (ERC20, ERC721 or ERC1155).
##### Burnable
This interface can burn voting power from a given wallet. This is just an amount and the implementer should decide how this maps to token ids and amounts.
## Token
### ERC20
#### Governance ERC20
This token is identical to the Governance ERC20 contract made by Aragon, only converted to a facet.
##### Governance ERC20 Burnable
This facet is an extension of Governance ERC20, allowing the token to be burned.
##### Governance ERC20 Disabled
This facet is an alteration of Governance ERC20, allowing functionality to be disabled. This will most often be used to create non-transferable and/or non-delegatable tokens.
### ERC721 and ERC1155
These token types are planned for the future. In all the code writen so far they have been kept in mind, so after implementation they will be compatible with the existing facets.
#### Claiming
##### Time based
Allows time based rewards to be available to be claimed by members of the DAO. There is also a tiered version allowing for members of different tiers to get different rewards. There is also a maximum amount of claimable tokens at once configurable, preventing inactive members from being able to claim a large sum of tokens after a long period of inactivity.
##### One time
Allows for a one time reward to be claimable. The most basic claimable facet of this type will be claimable once per wallet, given that the wallet is a member of the DAO. There is a second more advanced version which allows users to claim a reward for every verification that they pass.
## Permissions
The permission management defines which wallets are allowed to do certain actions. 
### AragonOSx
Currently this is the only permission provider, using the grant functionality of the DAO. However the implementation allows for more providers to be added in the future easily and also allows members to use their own custom permission provider if wanted.
## Other
### Verification
First plugin to implement [Secure SECO Verification](https://github.com/SecureSECODAO/SecureSECOVerification). Allowing wallets to become members of the DAO by verifying with their 1y old GitHub account or proof of humanity.
### GitHub Pull Request Merger
Allows the plugin to merge pull request on GitHub. This means that DAO members will be able to maintain the GitHub without needing to trust a centralized team of reviewers. This does however require some setup, which can be found on [their GitHub](https://github.com/SecureSECODAO/SecureSECOPullRequestMerger).
## Planned
This funcionality is planned to be added to the project in the future. These are based on requests seen in the Aragon Discord.
### Role based membership
Wallets are granted certain roles and based on this are allowed to use certain functionality of the plugin.
### NFT governance
Voting power based on certain ERC721 or ERC1155 tokens present in the wallet.
### Dashboard
Web portal to allow users to easily create a DAO with the Diamond Governance plugin and create proposals to alter the Diamond Governance plugin in existing DAOs.

**This point onwards is meant for developers of the projects, there will be no intresting information for regular users.**
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
Publishing to npm will be done automatically on merging with main in the future.

### Facet development
To learn more about facet development you can look into the [`FACET_DEV.md`](/FACET_DEV.md) file.

### License
The majority of the code is [MIT licensed](./LICENSE). However, there are some files that have been taken and modified from an [AGPL-3.0 licensed](https://www.gnu.org/licenses/agpl-3.0.en.html) project ([aragon/osx](https://github.com/aragon/osx)). The specific license of a file can be found at the very first lines of the file.

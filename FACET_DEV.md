# How to create a new facet
All facet contracts can be found in /contracts/facets. I'll be walking you through how to create a facet by using an example for Counter. okay someone please improve my English. This guide assumes you have basic knowledge on Solidity smart contract development. You can follow this CryptoZombies course to get started on learning Solidity.

## Contents
- Basic stuffs
- Facet storage
- Facet initialization

## Writing a facet contract
Facet development works as follows:

0. (Deploy a diamond)
1. Write a facet contract
2. Deploy the facet contract
3. Cut the facet into the diamond

First we create a new solidity contract in the `/facets` folder. Let's call this contract `CounterFacet.sol`. Our contract should specify a pragma and should ideally also specify an SDPX-license. 

### Basic facet example

#### **`CounterFacet.sol`**
```solidity
contract CounterFacet {
  /// @notice This function increments a number by 1
  /// @returns uint The new value of our number
  function incrementCounter() external returns (uint) {
    return 0; // We'll later replace this with the new value of our integer
  }
}
```

### Deploying the facet contract
We can add this facet to our diamond by cutting it into the diamond. The deployment scripts (for the diamond) are all located in the `/deployments` folder. There are a lot of files for deployment but for now we only need to focus on the `deploy_DiamondGovernance.ts` file (I'll explain what the rest is later).
To deploy the contract we need to do 3 things:

1. Deploying the contract in the function **deployDiamondGovernance()**.
    
    To deploy a contract in (hardhat) ethers, we can simply request the contract factory (abi/template) using the **ethers.getContractFactory("Your contract name")** method. We can then call the **factory.deploy()** method. It doesn't really matter where in the function you deploy the contract, but please do stick to our naming convention (...FacetContract for the Factory, and ...Facet for the deployed contract).

    Ideally you would also like to log that you've deployed the contract.
2. Add the contract type to the returned object.

    At the end of the **deployDiamondGovernance()** function we can see a returned object. We need to return the deployment of our facet in this object so we later use it to cut the facet into the diamond. First import your contract type at the top of the file. This should be imported from `../typechain-types`. Next add your type to the Facets field in the return interface called **DiamondDeployedContracts**. Finally add your facet to the returned object in the **deployDiamondGovernance()** function.

### Cutting the facet
In the same `deploy_DiamondGovernance.ts` file you can find a function called **createDiamondGovernanceRepo()**. At the top of the function you can see we call the **deployDiamondGovernance()** function where we previously deployed and returned our facet. To add our facet into the diamond we need to add/push an object into the "cut" array. This object should have the following structure:

#### **`deploy_DiamondGovernance.ts`**
```ts
{
  facetAddress: diamondGovernanceContracts.Facets.YourFacet.address, // Change this to your facet
  action: FacetCutAction.Add,
  functionSelectors: getSelectors(diamondGovernanceContracts.Facets.YourFacet) // Change this to your facet
}
```

Optionally you can also select only specific functions that you want to expose to the diamond.

```ts
functionSelectors: getSelectors(diamondGovernanceContracts.Facets.YourFacet).get(["foo(uint)", "bar(bool)"]).remove("foobar(address)")
```

That's it, you've now successfully added your very basic facet to the diamond. This facet currently doesn't have any storage nor initialization so let's add that next. (Also interface implementation has some special stuff we need to take care of so refer to the subparagraph on Inheritance for that please thanks).

## Facet storage
We currently don't have storage, the way storage works with our diamond structure is by creating a storage contract in `/contracts/facets/libraries/storage`. Our naming convention for this is `LibYourContractStorage.sol`, so `LibCounterStorage.sol` (note: without the "Facet"). A storage contract looks as follows:`

### Storage example

#### **`LibCounterStorage.sol`**
```solidity
library LibCounterStorage {
    bytes32 constant COUNTER_STORAGE_POSITION =
        keccak256("counter.diamond.storage.position"); // THIS SHOULD BE A UNIQUE HASH!!!

    // PUT YOUR STORAGE VARIABLES HERE!!!
    struct Storage {
        uint myNumber;
        // plus any other storage variables you might want...
    }

    function getStorage() internal pure returns (Storage storage ds) {
        bytes32 position = COUNTER_STORAGE_POSITION; // don't forget to change this variable name
        assembly {
            ds.slot := position
        }
    }
}
```

We can access this storage by importing the contract above and calling getStorage.

#### **`CounterFacet.sol`**
```solidity
contract CounterFacet {
  /// @notice This function increments our number by 1
  /// @returns uint The updated value of our number
  function incrementCounter() external returns (uint) {
    LibCounterStorage.Storage storage myStorage = LibCounterStorage.getStorage();
    myStorage.myNumber = myStorage.myNumber + 1; // You might want to replace this with SafeMath
    return myStorage.myNumber;
  }

  /// @notice Returns the current value of our number
  /// @returns uint The current value of our number
  function getCounter() external view returns (uint) {
    return LibCounterStorage.getStorage().myNumber;
  }
}
```

## Facet initialization

Now let's say we wanted to have an initial number. Usually you would have put your initialization in the constructor but for our diamond we need a separate init function. To do this add a library at the top of your `CounterFacet.sol` file.

#### **`CounterFacet.sol`**
```solidity
library CounterFacetInit {
    // PUT YOUR INITIALIZATION PARAMETERS HERE AS YOU WOULD FOR YOUR CONSTRUCTOR
    struct InitParams {
        uint myInitialNumber;
    }

    // INITIALIZE YOUR STORAGE VARIABLES HERE
    function init(InitParams calldata _params) external {
        LibCounterStorage.Storage storage s = LibCounterStorage.getStorage();

        s.myNumber = _params.myInitialNumber;
    }
}

contract CounterFacet { ... }
```

We now have a init function but we still don't call it anywhere. To call this function we need to add the library to the `DiamondInit.sol` file. Add your file import like so:

#### **`DiamondInit.sol`**
```solidity
import { CounterFacetInit } from "../facets/CounterFacet.sol";
```

Then in the **init()** function in the **DiamondInit** contract, we add our InitParams to the parameters fo the **init()** function and at the bottom of the same function we add the call to the **init()** function (of the **CounterFacetInit**) with parameters. Like so:

#### **`DiamondInit.sol`**
```solidity
contract DiamondInit {    
    function init(
        CounterFacetInit.InitParams memory _counterSettings
    ) external {
        // ... some ERC165 stuff

        CounterFactInit.init(_counterSettings);
    }
}
```

Next we deploy our library. We add our library to the **deployLibraries()** function in `deploy_Libraries.ts` file.

#### **`deploy_Libraries.ts`**
```ts
interface Libraries {
    // ...
    CounterFacetInit: string;
}

async function deployLibraries() : Promise<Libraries> {
    // ...
    const CounterFacetInitContract = await ethers.getContractFactory("CounterFacetInit");
    const CounterFacetInit = await CounterFacetInitContract.deploy();

    return {
        // ...
        CounterFacetInit: CounterFacetInit.address,
    };
}
```

Then add the address of the deployed library to the parameters at the top of the **deployDiamondGovernance()** function.

#### **`deploy_DiamondGovernance.ts`**
```ts
const DiamondInitContract = await ethers.getContractFactory('DiamondInit', { 
  libraries: {
    // ...
    CounterFacetInit: libraries.CounterFacetInit,
  }
});
```

Then in the **createDiamondGovernanceRepo()** function:

#### **`deploy_DiamondGovernance.ts`**
```ts
async function createDiamondGovernanceRepo(/*...*/) {
  // ... cutting stuff

  // ... other settings

  const counterSettings = {
    myInitialNumber: 7,
  }

  const constructionArgs = {
    _diamondCut: cut,
    _init: diamondGovernanceContracts.DiamondInit.address,
    _calldata: diamondGovernanceContracts.DiamondInit.interface.encodeFunctionData("init", [/*...other_settings, */ counterSettings])
  };
  
  // installation stuff
}
```

That's about it for the initialization stuff.

## Inheriting from interfaces

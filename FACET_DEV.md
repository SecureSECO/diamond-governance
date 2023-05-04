# How to create a new facet
This guide will walk you through the steps on how to create a facet by using a Counter implementation as an example. 
This counter will simply store a number and increment it after a function is called.
All facet contracts can be found in /contracts/facets.
This guide assumes you have basic knowledge on Solidity smart contract development, ethers.js, and Chai testing. 
You can follow this [CryptoZombies](https://cryptozombies.io/) course to get started on learning Solidity.

Everytime you modify your solidity files and get a type error somewhere, don't forget to run `npm run compile` or `npx hardhat compile`. 
If this doesn't work you can try running `npx hardhat clean` (before running the above commands again) and see if that works.

<!-- If that doesn't work consider having written faulty code and stop blaming other people/things for your own mistakes <3. -->

## Contents
- [Writing a facet contract](#writing-a-facet-contract)
  - [Write a facet contract](#write-a-facet-contract)
  - [Deploy the facet contract](#deploying-the-facet-contract)
  - [Cutting the facet](#cutting-the-facet)
- [Facet storage](#facet-storage)
  - [Storage contract](#libcounterstoragesol)
  - [Storage access](#counterfacetsol-1)
- [Facet initialization](#facet-initialization)
  - [Write an init function](#write-an-init-function)
  - [Add an init call](#add-init-call-in-central-init-function)
  - [Deploy your library](#deploy-your-library)
  - [Add your parameters](#add-your-parameters)
- [Testing your facets](#testing-your-facets)
  - [With the whole diamond](#deploying-the-whole-diamond)
  - [Isolated testing](#deploying-just-the-base-diamond)

## Writing a facet contract
Facet development works as follows:

0. (Deploy a diamond)
1. Write a facet contract
2. Deploy the facet contract
3. Cut the facet into the diamond

### Write a facet contract
First create a new solidity contract in the `/facets` folder. 
Let's call this contract `CounterFacet.sol`. 
This contract should specify a pragma and should ideally also specify an SDPX-license. 

#### **`CounterFacet.sol`**
```solidity
contract CounterFacet {
  /// @notice This function increments a number by 1
  /// @returns uint The new value of our number
  function incrementCounter() external returns (uint) {
    return 0; // This value will be replaced with the new incremented value of our integer later 
  }
}
```

### Deploying the facet contract
This facet can be added to our diamond by cutting it into the diamond. 
The deployment scripts (for the diamond) are all located in the `/deployments` folder. 
There are a lot of files for deployment but for now the only relevant one is `deploy_DiamondGovernance.ts` (it will become clear later what the other files are for).
3 things must be done to deploy the contract:

1. Deploying the contract in the function **deployDiamondGovernance()**.
    
    In order to deploy a contract in (hardhat) ethers, 
    the contract factory (abi/template) must first be requested using the **ethers.getContractFactory("Your contract name")** method. 
    The contract can then be deployed by calling the **factory.deploy()** method. 
    It doesn't really matter where in the function you deploy the contract, but please do stick to the existing naming convention (...FacetContract for the Factory, and ...Facet for the deployed contract).

    Ideally you would also like to log that you've deployed the contract.

    #### **`deploy_DiamondGovernance.ts`**
    ```ts
    async function deployDiamondGovernance() : Promise<DiamondDeployedContracts> {
      /* ... */
      
      const CounterFacetContract = await ethers.getContractFactory("CounterFacet");
      const CounterFacet = await CounterFacetContract.deploy();
      console.log(`CounterFacet deployed at ${CounterFacet.address}`);
      
      /* ... */
    }
    ```
2. Add the contract type to the returned object.

    At the end of the **deployDiamondGovernance()** function there is a returned object. 
    This object should be used to return the deployment of our facet in this object so the facet can later be cut (added) into the diamond. 
    First import your contract type at the top of the file. 
    This should be imported from `../typechain-types`. 
    Next add your type to the Facets field in the return interface called **DiamondDeployedContracts**. 
    Finally add your facet to the returned object in the **deployDiamondGovernance()** function.

    #### **`deploy_DiamondGovernance.ts`**
    ```ts
    // Types
    import { CounterFacet } from "../typechain-types"; // Import facet type here
    
    /* ... */

    interface DiamondDeployedContracts {
      /* ... */
      Facets: {
        /* ... */
        Counter: CounterFacet; // Change this here
      }
    }

    /* ... */

    async function deployDiamondGovernance() : Promise<DiamondDeployedContracts> {
      /* ... */
      
      return {
        /* ... */
        Facets: {
          /* ... */
          Counter: CounterFacet, // Change this here
        }
      };
    }
    ```

### Cutting the facet
In the same `deploy_DiamondGovernance.ts` file you can find a function called **createDiamondGovernanceRepo()**. 
At the top of the function there is function a call to **deployDiamondGovernance()**, where our facet was previously deployed and returned. 
To add your facet into the diamond, an object must be added/pushed into the "cut" array. This object should have the following structure:

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

That's it, you've now successfully added your very basic facet to the diamond. 
This facet currently doesn't have any storage nor initialization so this guide will show you how to add that next. 
(Also if your contract implements an interface, the diamond has to show that you implement that interface through ERC165 so refer to the subparagraph on [Inheritance](#inheriting-from-interfaces) how to do that).

## Facet storage
The Counter facet currently doesn't have any storage, the way storage works with our diamond structure is by creating a storage contract in `/contracts/libraries/storage`. Our naming convention for this is `LibYourContractStorage.sol`, so `LibCounterStorage.sol` (note: without the "Facet"). A storage contract looks as follows:`

### Storage example

#### **`LibCounterStorage.sol`**
```solidity
library LibCounterStorage {
    bytes32 constant COUNTER_STORAGE_POSITION =
        keccak256("counter.diamond.storage.position"); // This should be a unique hash!

    // Put your storage variables here
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

Suppose our facet needs to have an initial number. 
It is not possible to simply create a constructor because this constructor will be executed when the facet is deployed (and not cut) and the variables it sets will not be shared with the diamond. 
The diamond also cannot execute the constructor when the facet is cut into the diamond.

The way initialization works in our diamond structure is as follows:
1. Write a "init" function in a separate "library contract".
2. All init functions are called from a central init function. Add a call to your init function here.
3. It is not possible to make a call to a non-deployed library. Add a deployment for your library.
4. Add your parameters to the function call to the central init function.

This might seem a bit confusing at first, but it is much simpler than it seems. 
This guide will show you step-by-step how to add initialization to your facet.

### Write an init function
Usually initialization is done in the constructor but for our diamond a separate "init" function is needed. 
To do this add a library at the top of your `CounterFacet.sol` file.

#### **`CounterFacet.sol`**
```solidity
library CounterFacetInit {
    // Put your initialization parameters here as you would for your constructor
    struct InitParams {
        uint myInitialNumber;
    }

    // Initialize your storage variables here
    function init(InitParams calldata _params) external {
        LibCounterStorage.Storage storage s = LibCounterStorage.getStorage();

        s.myNumber = _params.myInitialNumber;
    }
}

contract CounterFacet { ... }
```

### Add init call in central init function
The `DiamondInit.sol` file acts like a central init function that calls all initialization functions.
The **init()** function has been created but it isn't called anywhere. 
To call this function the library needs to be added to the `DiamondInit.sol` file. 
Add your file import like so:

#### **`DiamondInit.sol`**
```solidity
import { CounterFacetInit } from "../facets/CounterFacet.sol";
```

Then in the **init()** function in the **DiamondInit** contract, 
add the InitParams to the parameters for the **init()** function 
and at the bottom of the same function add the call to the **init()** function (of the **CounterFacetInit**) with parameters. Like so:

#### **`DiamondInit.sol`**
```solidity
contract DiamondInit {    
    function init(
        /* ... other settings */
        CounterFacetInit.InitParams memory _counterSettings // Change this here
    ) external {
        // ... some ERC165 stuff

        CounterFactInit.init(_counterSettings); // Change this here
    }
}
```

### Deploy your library
Next the (init) library must be deployed. Add your library to the **deployLibraries()** function in `deploy_Libraries.ts` file.

#### **`deploy_Libraries.ts`**
```ts
interface Libraries {
    // ...
    CounterFacetInit: string; // Change this here
}

async function deployLibraries() : Promise<Libraries> {
    // ...
    const CounterFacetInitContract = await ethers.getContractFactory("CounterFacetInit"); // Change this here
    const CounterFacetInit = await CounterFacetInitContract.deploy(); // Change this here

    return {
        // ...
        CounterFacetInit: CounterFacetInit.address, // Change this here
    };
}
```

Then add the address of the deployed library to the parameters at the top of the **deployDiamondGovernance()** function.

#### **`deploy_DiamondGovernance.ts`**
```ts
const DiamondInitContract = await ethers.getContractFactory('DiamondInit', { 
  libraries: {
    // ...
    CounterFacetInit: libraries.CounterFacetInit, // Change this here
  }
});
```

### Add your parameters
Now in the **createDiamondGovernanceRepo()** function, add your parameters/settings:

#### **`deploy_DiamondGovernance.ts`**
```ts
async function createDiamondGovernanceRepo(/*...*/) {
  // ... cutting stuff

  // ... other settings

  const counterSettings = { // Change this here
    myInitialNumber: 7,
  }

  const constructionArgs = {
    _diamondCut: cut,
    _init: diamondGovernanceContracts.DiamondInit.address,
    _calldata: diamondGovernanceContracts.DiamondInit.interface.encodeFunctionData("init", [/*...other_settings, */ counterSettings]) // Change this here
  };
  
  // installation stuff
}
```

That's about it for the initialization stuff.

## Inheriting from interfaces
Interfaces are really nice. Interfaces create standards and consensus between developers all around the world. Another neat thing about interfaces is that we can fairly easily swap out our current Counter implementation with a new one if we wanted to (as long as they both implement the interface).

Suppose we have the following interface (we can add this in the same folder as we added `CounterFacet.ts`):

#### **`ICounter.sol`**
```solidity
interface ICounter {
  /// @notice This function increments a number by 1
  /// @returns uint The new value of our number
  function incrementCounter() external returns (uint);
}
```

We can implement it as follows.

#### **`CounterFacet.sol`**
```solidity
contract CounterFacet is ICounter {
  /// @inheritdoc CounterInterface
  function incrementCounter() external returns (uint) { /*...*/ }
}
```

Add the interface to the interface ids in `/utils/InterfaceIds.sol`.

```solidity
import { ICounter } from "../facets/ICounter.sol";

library InterfaceIds {
    // ... other interfaces
    bytes4 constant public ICounter = type(ICounter).interfaceId; // Change this here
}
```

Now we show the world that we implement this interface (ERC165) in the `DiamondInit.sol` file.

#### **`DiamondInit.sol`**
```solidity
import { ICounter } from "../utils/InterfaceIds.sol";

// ...

contract DiamondInit {    
    function init(/* ... */) external {
        // adding ERC165 data
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        ds.supportedInterfaces[type(ICounter).interfaceId] = true; // Change this here

        // ... 
    }
}
```

That's about it for interface implementation.

## Testing your facets
All tests must be placed within the `/test` folder. Tests are written in Chai. There are two ways to test your facets. 

1. Using the full fletched diamond with all the other facets.
2. Using the base diamond provided by us and adding the facet on top. (Isolated facet testing)

It is recommended to use method 2, because this reduces the influence of outside factors (isolated testing is nicer).

### Deploying the whole diamond
First create a test file `/test/Test_Counter1.ts`. 
To get a diamond and the relevant data needed to test your facets, simply call the function **deployAragonDAOWithFramework()** found in `/deployments/deploy_AragonDAO.ts`. 
It is however strongly recommended you use the **loadFixture()** functionality, because this will revert the local (hardhat) blockchain to the last saved point.

#### **`Test_Counter1.ts`**
```ts
import { ethers } from "hardhat";
import { expect } from "chai";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";

describe("Counter facet", function () {
  it("should increment a number!", async function () {
    const { DiamondGovernance, diamondGovernanceContracts, verificationContractAddress, DAO } = await loadFixture(deployAragonDAOWithFramework);

    const CounterFacet = await ethers.getContractAt("CounterFacet", DiamondGovernance.address);
    // Number should be 7 initially (due to init settings)
    const myNumber = await CounterFacet.getCounter();
    expect(myNumber).to.be.equal(7);

    const incrementedNumber = await CounterFacet.incrementCounter();

    expect(incrementedNumber).to.be.equal(8);

    // Number should be 8 after incrementing
    const myNewNumber = await CounterFacet.getCounter();
    expect(myNewNumber).to.be.equal(incrementedNumber);
  });
});
```

### Deploying just the base diamond
To get a minimal deploy of the diamond (without all the other facets), a separate init file must be created, our central init doesn't work here because it calls init functions that aren't added to the diamond. 
Let's go ahead and create `DICounter.sol` (DI stands for DiamondInit) in `/contracts/upgrade-initializers/single-contract-init`. 
The contents of this file should be similar to the contents we talked about in the [Facet Initialization](#facet-initialization) section.

#### **`DICounter.sol`**
```solidity
contract DICounter {
    function init(
        CounterFacetInit.InitParams memory _counterSettings // Change this here
    ) external {
        // adding ERC165 data
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        ds.supportedInterfaces[type(ICounter).interfaceId] = true; // Change this here

        CounterFacetInit.init(_counterSettings); // Change this here
    }
}
```

Our tests can then be written in `/test/Test_Counter2.ts`.
Note that **deployBaseAragonDAO** is used here and not **deployAragonDAOWithFramework**.

#### **`Test_Counter2.ts`**
```ts
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { deployBaseAragonDAO } from "../deployments/deploy_BaseAragonDAO";
import { DiamondDeployedContractsBase, addFacetToDiamondWithInit } from "../deployments/deploy_DGSelection";

describe("Counter facet", () => {
  it("test some specific counter facet stuff", async () => {
    const { DiamondGovernance, diamondGovernanceContracts } = await loadFixture(deployBaseAragonDAO);

    // Contract names
    const contractNames = {
      facetContractName: "CounterFacet",
      facetInitContractName: "CounterFacetInit",
      diamondInitName: "DICounter",
    }

    // Deploy facet contract
    const counterSettings = {
      myInitialNumber: 7,
    }

    await addFacetToDiamondWithInit(diamondGovernanceContracts, DiamondGovernance.address, contractNames, counterSettings);

    // We can now access our facet through the diamond
    const CounterFacet = await ethers.getContractAt("CounterFacet", DiamondGovernance.address);
    // Number should be 7 initially (due to init settings)
    const myNumber = await CounterFacet.getCounter();
    expect(myNumber).to.be.equal(7);
  });
});
```

A nice way to structure this is to split the above function up so the facet cutting can then later be reused in other tests. Like this:

#### **`/test/facet-selection/addSingleFacet.ts`**
```ts
const addCounterFacet = async (diamondGovernanceContracts: DiamondDeployedContractsBase, diamondGovernanceAddress: string) => {
  // Contract names
  const contractNames = { /* ... */ }

  // Deploy facet contract
  const counterSettings = { /* ... */ }

  await addFacetToDiamondWithInit(diamondGovernanceContracts, diamondGovernanceAddress, contractNames, counterSettings);
}
```

#### **`Test_Counter2.ts`**
```ts
describe("Counter facet", () => {
  it("test some counter facet stuff", async () => {
    const { DiamondGovernance, diamondGovernanceContracts } = await loadFixture(deployBaseAragonDAO);

    // Add CounterFacet to the diamond
    await addCounterFacet(diamondGovernanceContracts, DiamondGovernance.address);

    // We can now access our facet through the diamond
    const CounterFacet = await ethers.getContractAt("CounterFacet", DiamondGovernance.address);
    // Number should be 7 initially (due to init settings)
    const myNumber = await CounterFacet.getCounter();
    expect(myNumber).to.be.equal(7);
  });
});
```

### What to do when your function is 'auth'ed?
Some functions can only be called from within the diamond. 
To test these functions you can create a "mock" facet that exposes a function that calls the private or authed function. 
The mock itself should generally not need initialization or storage, and should never be included in the diamond outside of tests. 
This mock can then be used to test in the same way as a normal facet.

We'll leave this as an exercise to the reader.

<!-- ## Closing notes
Thank you for reading my guide on facet development, I hope you learned something. I wish you the best of luck on your journey to becoming a diamond guru! -->
# How to create a new facet
This guide will walk you through the steps on how to create a facet by using a Counter implementation as an example. 
This counter will simply store a number and increment it after a function is called.
All facet contracts can be found in /contracts/facets.
This guide assumes you have basic knowledge on Solidity smart contract development, ethers.js, and Chai testing. 
You can follow this [CryptoZombies](https://cryptozombies.io/) course to get started on learning Solidity.

Everytime you modify your solidity files and get a type error somewhere, don't forget to run `npm run compile` or `npx hardhat compile`. 
If this doesn't work you can try running `npx hardhat clean` (before running the previous command again) and see if that works.

The complete example facet (and other files used in this guide) can be found in the [`example-facet`](/example-facet) directory.

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
  - [Add your parameters](#add-your-parameters)
- [Exposing getters/setters](#exposing-getterssetters)
- [Inheriting from interfaces](#inheriting-from-interfaces)
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
Every facet should follow the following structure/template.

#### **`CounterFacet.sol`**
```solidity
contract CounterFacet is IFacet {
  /// @inheritdoc IFacet
  function init(bytes memory /*_initParams*/) public virtual override { }

  /* This init function is needed for the (typescript) deployment to automatically
   * detect the parameters for initialization.
   * The naming convention for this function is as follows:
   * __[ContractName]_init()
   */
  function __CounterFacet_init() public virtual { }

  /// @inheritdoc IFacet
  function deinit() public virtual override {
    super.deinit(); // call the deinit() function of the superclass as convention.
  }

  /// @notice This function increments a number by 1
  /// @return uint The new value of our number
  function incrementCounter() external returns (uint) {
    return 0; // This value will be replaced with the new incremented value of our integer later 
  }
}
```

### Deploying the facet contract
Your facet will get automatically detected and deployed to the blockchain network. 
You don't have to do anything.

### Cutting the facet
Now that your facet is deployed, it is time to cut it into (add it to) the diamond.

You can achieve this feat by opening the `Deploy.ts` file in the `scripts` folder, and modifying the cut array as such:

#### **`Deploy.ts`**
```ts
const cut : DiamondCut[] = [
  // ...
  await DiamondCut.All(diamondGovernance.CounterFacet),
];
```

It is also possible to pick only a specific subset of functions to expose. You will need need to use either the `Only` or `Except` functions. Some examples:
```ts
await DiamondCut.Only(diamondGovernance.GovernanceERC20DisabledFacet, ERC20Disabled),
await DiamondCut.Except(diamondGovernance.GovernanceERC20BurnableFacet, ERC20Disabled, [erc20Settings]),
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
  /* ... init related functions */

  /// @notice This function increments our number by 1
  /// @returns uint The updated value of our number
  function incrementCounter() external returns (uint) {
    LibCounterStorage.Storage storage myStorage = LibCounterStorage.getStorage();
    myStorage.myNumber = myStorage.myNumber + 1; // You might want to replace this with SafeMath
    return myStorage.myNumber;
  }

  /// @notice Returns the current value of our number
  /// @return uint The current value of our number
  function getCounter() external view returns (uint) {
    return LibCounterStorage.getStorage().myNumber;
  }
}
```

## Facet initialization

Suppose our facet needs to have an initial number. 
It is not possible to simply create a constructor because this constructor will be executed when the facet is deployed (and not cut) and the variables it sets will not be shared with the diamond (no access to the previously created storage). 
The diamond also cannot execute the constructor when the facet is cut into the diamond.

This is why the CounterFacet implements IFacet and needs to have a unique init function.
1. Create a struct for your init parameters
2. Decode the parameters and sets the storage variables
3. (Optional) Call the init function of the superclass

This might seem a bit confusing at first, but it is much simpler than it seems. 
This guide will show you step-by-step how to add initialization to your facet.

### Write an init function
Usually initialization is done in the constructor but for our diamond a separate "init" function is needed. 
For now the **deinit()** function can be ignored, it will be explained in the next section.

#### **`CounterFacet.sol`**
```solidity
contract CounterFacet is IFacet {
  struct CounterFacetInitParams {
    uint myNumber;
  }

  /// @inheritdoc IFacet
  function init(bytes memory _initParams) public virtual override { 
    // Decode the parameters
    CounterFacetInitParams memory _params = abi.decode(_initParams, (CounterFacetInitParams));
    // Set the storage variables using the unique init
    __CounterFacet_init(_params);
  }

  /* This init function is needed for the (typescript) deployment to automatically
   * detect the parameters for initialization.
   */
  function __CounterFacet_init(CounterFacetInitParams memory _initParams) public virtual { 
    LibCounterStorage.Storage storage ds = LibCounterStorage.getStorage();
    ds.myNumber = _initParams.myNumber;
  }

  /// @inheritdoc IFacet
  function deinit() public virtual override {
    super.deinit(); // call the deinit() function of the superclass as convention.
  }

  /* ... other functions */
}
```

The deployment script will automatically detect the init parameters and encode them for you.
It will also call the init function upon cutting the facet into the diamond.
You will still need to add the parameters to the deployment script though.

### Add your parameters
Now in the **main()** function (in `Deploy.ts`), add your parameters/settings:

#### **`Deploy.ts`**
```ts
const cut : DiamondCut[] = [
  // ...
  const counterSettings = {
    myNumber: 0,
  };

  await DiamondCut.All(diamondGovernance.CounterFacet, [counterSettings]),
];
```

That's about it for the initialization stuff.

## Exposing getters/setters
It is possible to automatically expose getters/setters (for the storage variables) in your facet through the sdk.
This is done by following the following naming convention (the sdk will automatically detect this):

```solidity
function get<variableName> () external view returns (<variableType>) {}
set<variableName> (<variableType> _<variableName>) external {}
```

In our example that would be:

```solidity
contract CounterFacet {
  /* ... init related functions */

  function getMyNumber() external view returns (uint) {
    return LibCounterStorage.getStorage().myNumber;
  }

  function setMyNumber(uint _myNumber) external {
    LibCounterStorage.getStorage().myNumber = _myNumber;
  }
}
```

Note that the function name should be camelCase and the first letter of the variable should be capitalized.
The parameter name should be the same as the variable name but with an `_` in front of it.
You can freely add other modifiers to these functions as well. 

These getters/setters are now available through the sdk:

```ts
const allVariables = await client.sugar.GetVariables();
```

This function only returns the variable names and relevant interfaces, so you'll still have to call the functions yourself.

## Inheriting from interfaces
Interfaces are really nice. 
Interfaces create standards and consensus between developers all around the world. 
Another neat thing about interfaces is that we can fairly easily swap out our current Counter implementation with a new one if we wanted to (as long as they both implement the interface).

Suppose we have the following interface (we can add this in the same folder as we added `CounterFacet.ts`):

#### **`ICounterFacet.sol`**
```solidity
interface ICounterFacet {
  /// @notice This function increments a number by 1
  /// @return uint The new value of our number
  function incrementCounter() external returns (uint);

  /// @notice This function returns our number
  /// @return uint The value of our number
  function getMyNumber() external view returns (uint);

  /// @notice This function sets our number
  /// @param _myNumber The new value of our number
  function setMyNumber(uint _myNumber) external;
}
```

We can implement it as follows.

#### **`CounterFacet.sol`**
```solidity
contract CounterFacet is ICounterFacet, IFacet {
  /* ... init related functions */

  /// @inheritdoc ICounterFacet
  function incrementCounter() external override returns (uint) { /*...*/ }

  /// @inheritdoc ICounterFacet
  function getMyNumber() external view override returns (uint) { /*...*/ }
  
  /// @inheritdoc ICounterFacet
  function setMyNumber(uint _myNumber) external override { /*...*/ }
}
```

To support the interface call the function **registerInterface()** in the init function of your facet.

#### **`CounterFacet.sol`**
```solidity
contract CounterFacet is ICounter, IFacet {
  /* ... init related functions */

  function __CounterFacet_init(CounterFacetInitParams memory _initParams) public virtual { 
    /* ... initialization stuff */

    // This function comes from IFacet, it adds the interface to the supported interfaces
    registerInterface(type(ICounter).interfaceId); // Change this here
  }

  /* ... other functions */
}
```

When the facet is cut into the diamond, the init will add the interface to the supported interfaces, but the interface will still be supported after the facet is removed from the diamond.
The interface should be unregistered in the deinit function.

#### **`CounterFacet.sol`**
```solidity
contract CounterFacet is ICounterFacet, IFacet {
  /* ... init related functions */

  /// @inheritdoc IFacet
  function deinit() public virtual override {
    super.deinit(); // call the deinit() function of the superclass as convention.

    // This function comes from IFacet, it removes the interface from the supported interfaces
    unregisterInterface(type(ICounterFacet).interfaceId); // Change this here
  }

  /* ... other functions */
}
```

Anything else that needs to be run when the facet is removed from the diamond can be added to the deinit function too.

That's about it for interface implementation.

## Testing your facets
All tests must be placed within the `/test` folder. 
Tests are written in Chai. 
The tests are run using the hardhat framework.

#### **`Test_Counter1.ts`**
```ts
async function getClient() {
  await loadFixture(deployTestNetwork);
  const [owner] = await ethers.getSigners();
  const diamondGovernance = await getDeployedDiamondGovernance(owner);

  // The settings for the CounterFacet
  const CounterFacetSettings = { // Change this
    myNumber: 0,
  };
  const cut : DiamondCut[] = [ // Change this
    ...await defaultDiamondCut(diamondGovernance),
    await DiamondCut.All(diamondGovernance.CounterFacet, [CounterFacetSettings]),
  ];

  const settings : DAOCreationSettings = {
    trustedForwarder: ethers.constants.AddressZero,
    daoURI: "https://plopmenz.com",
    subdomain: "mydao",
    metadata: {
      name: "Name",
      description: "Description",
      links: [],
      avatar: "Avatar"
    },
    diamondCut: cut,
    additionalPlugins: []
  };
  const dao = await CreateDAO(settings, owner);
  return new DiamondGovernanceClient(dao.diamondGovernance.address, owner);
}

// Write your test(s) here
describe("CounterFacet", function () {
  it("should increment a number!", async function () {
    const client = await loadFixture(getClient);
    const ICounter = await client.pure.ICounter();

    const myNumber = await ICounter.getCounter();
    expect(myNumber).to.be.equal(7);

    const incrementedNumber = await ICounter.incrementCounter();

    expect(incrementedNumber).to.be.equal(8);

    // Number should be 8 after incrementing
    const myNewNumber = await ICounter.getCounter();
    expect(myNewNumber).to.be.equal(incrementedNumber);
  });
});
```

### What to do when your function is 'auth'ed?
Some functions can only be called from within the diamond. 
To be still able to test this functionality you can swap out AuthConsumer for AuthConsumerMock in the tests.
This is done by default so you don't have to worry about it.

<!-- ## Closing notes
Thank you for reading my guide on facet development, I hope you learned something. I wish you the best of luck on your journey to becoming a diamond guru! -->
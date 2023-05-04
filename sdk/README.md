### Diamond Governace SDK
TypeScript wrapper for the Diamond Governance smart contract calls.

### Example
```
const DiamondGovernanceAddress = "< insert address of Diamond Contract >";
const [owner] = await ethers.getSigners();
const client = new DiamondGovernanceClient(DiamondGovernanceAddress, owner);
const IERC165 = await client.pure.IERC165();
console.log(await IERC165.supportsInterface("0x01ffc9a7"));
```
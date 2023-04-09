import { ethers } from "hardhat";
import { Signer } from "@ethersproject/abstract-signer";
import { IERC165, /* interfaces */ } from "../typechain-types";

enum DiamondGovernanceInterfaces { IERC165, /* interfaces */ }

export class DiamondGovernanceClient {
    private pluginAddress : string;
    private signer : Signer;
    private cache: { [id: string] : any }

    public constructor(_pluginAddress : string, _signer : Signer) {
        this.pluginAddress = _pluginAddress;
        this.signer = _signer;
        this.cache = { };
        Object.freeze(this);
    }

    public async IERC165() : Promise<IERC165> {
        return await this._get<IERC165>(DiamondGovernanceInterfaces.IERC165, "");
    }
    /* interface methods */

    private async _get<Type>(_interface : DiamondGovernanceInterfaces, _interfaceId : string) : Promise<Type> {
        if (this.cache.hasOwnProperty(_interface)) {
            return this.cache[_interface] as Type;
        }
        
        const name = DiamondGovernanceInterfaces[_interface];
        const contract = await ethers.getContractAt(name, this.pluginAddress, this.signer) as Type;
        if (_interface !== DiamondGovernanceInterfaces.IERC165) {
            if (_interfaceId === null || _interfaceId === undefined) {
                throw new Error("Invalid interfaceId");
            }
            
            const ierc165 = await this.IERC165();
            const isSupported = await ierc165.supportsInterface(_interfaceId);
            if (!isSupported) {
                throw new Error("Interface not supported by the diamond");
            }
        }
        this.cache[name] = contract;
        return contract;
    }
}
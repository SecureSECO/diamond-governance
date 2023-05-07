/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  *
  * This source code is licensed under the MIT license found in the
  * LICENSE file in the root directory of this source tree.
  */

import { ethers } from "hardhat";
import { Signer } from "@ethersproject/abstract-signer";
import { IERC165, /* interfaces */ } from "../../typechain-types";

enum DiamondGovernanceInterfaces { IERC165, /* interfaces */ }

class DiamondGovernancePure {
    public pluginAddress : string;
    public signer : Signer;
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

export { DiamondGovernanceInterfaces, DiamondGovernancePure, IERC165, /* interfaces */ }
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  *
  * This source code is licensed under the MIT license found in the
  * LICENSE file in the root directory of this source tree.
  */

import { Contract } from "ethers";
import { Signer } from "@ethersproject/abstract-signer";
import { GetTypedContractAt } from "../utils/contractHelper";
import { IERC165, /* interfaces */ } from "../typechain-types";

enum DiamondGovernanceInterfaces { IERC165, /* interfaces */ }

class DiamondGovernancePure {
    public readonly pluginAddress : string;
    public readonly signer : Signer;
    public skipInterfaceCheck : boolean;
    private cache: { [id: string] : Contract }

    public constructor(_pluginAddress : string, _signer : Signer) {
        this.pluginAddress = _pluginAddress;
        this.signer = _signer;
        this.skipInterfaceCheck = false;
        this.cache = { };
    }

    public async IERC165() : Promise<IERC165> {
        return await this._get<IERC165>(DiamondGovernanceInterfaces.IERC165, "");
    }
    /* interface methods */

    public async GetCustomInterface(_name : string, _abi : any[], _interfaceId : string | undefined) : Promise<Contract> {
        if (this.cache.hasOwnProperty(_name)) {
            return this.cache[_name];
        }

        if (_interfaceId != undefined) {
            const ierc165 = await this.IERC165();
            const isSupported = await ierc165.supportsInterface(_interfaceId);
            if (!isSupported) {
                throw new Error("Interface not supported by the diamond");
            }
        }
        
        const contract = new Contract(this.pluginAddress, _abi, this.signer);
        this.cache[_name] = contract;
        return contract;
    }

    private async _get<Type extends Contract>(_interface : DiamondGovernanceInterfaces, _interfaceId : string) : Promise<Type> {
        if (this.cache.hasOwnProperty(_interface)) {
            return this.cache[_interface] as Type;
        }
        
        if (_interface !== DiamondGovernanceInterfaces.IERC165 && !this.skipInterfaceCheck) {
            if (_interfaceId === null || _interfaceId === undefined) {
                throw new Error("InterfaceId not provided");
            }
            
            const ierc165 = await this.IERC165();
            const isSupported = await ierc165.supportsInterface(_interfaceId);
            if (!isSupported) {
                throw new Error("Interface not supported by the diamond");
            }
        }

        const name = DiamondGovernanceInterfaces[_interface];
        const contract = await GetTypedContractAt<Type>(name, this.pluginAddress, this.signer);
        this.cache[name] = contract;
        return contract;
    }
}

export { DiamondGovernanceInterfaces, DiamondGovernancePure, IERC165, /* interfaces */ }
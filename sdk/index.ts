import { Signer } from "@ethersproject/abstract-signer";

import { DiamondGovernancePure } from "./src/client";
import { DiamondGovernanceSugar } from "./src/sugar";

export class DiamondGovernanceClient {
    public pure: DiamondGovernancePure;
    public sugar: DiamondGovernanceSugar;

    constructor(_pluginAddress : string, _signer : Signer) {
        this.pure = new DiamondGovernancePure(_pluginAddress, _signer);
        this.sugar = new DiamondGovernanceSugar(this.pure);
    }
}

export * from "./src/client";
export * from "./src/sugar";
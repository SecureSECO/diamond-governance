import { Signer } from "@ethersproject/abstract-signer";

import { DiamondGovernancePure } from "./src/client";
import { DiamondGovernanceSugar } from "./src/sugar";
import { VerificationSugar } from "./src/verification";

export class DiamondGovernanceClient {
    public pure: DiamondGovernancePure;
    public sugar: DiamondGovernanceSugar;
    public verification: VerificationSugar;

    constructor(_pluginAddress : string, _signer : Signer) {
        this.pure = new DiamondGovernancePure(_pluginAddress, _signer);
        this.sugar = new DiamondGovernanceSugar(this.pure);
        this.verification = new VerificationSugar(this.sugar, _signer);
    }
}

export * from "./src/client";
export * from "./src/sugar";
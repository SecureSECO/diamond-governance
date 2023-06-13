import { Signer } from "@ethersproject/abstract-signer";

import { DiamondGovernancePure } from "../generated/client";
import { DiamondGovernanceSugar } from "./src/sugar";
import { VerificationSugar } from "./src/verification";

/// The class exposed by the package import, through which all interactions are performed.

export class DiamondGovernanceClient {
    public pure: DiamondGovernancePure;
    public sugar: DiamondGovernanceSugar;
    public verification: VerificationSugar;

    constructor(_pluginAddress : string, _signer : Signer) {
        this.pure = new DiamondGovernancePure(_pluginAddress, _signer);
        this.sugar = new DiamondGovernanceSugar(this.pure);
        this.verification = new VerificationSugar(this.sugar, _signer);
    }

    public Update(_pluginAddress : string, _signer : Signer) {
        this.pure = new DiamondGovernancePure(_pluginAddress, _signer);
        this.sugar = new DiamondGovernanceSugar(this.pure);
        this.verification = new VerificationSugar(this.sugar, _signer);
    }

    public UpdateAddress(_pluginAddress : string) {
        this.Update(_pluginAddress, this.pure.signer);
    }

    public UpdateSigner(_signer : Signer) {
        this.Update(this.pure.pluginAddress, _signer);
    }
}

export * from "../generated/client";
export * from "./src/sugar";
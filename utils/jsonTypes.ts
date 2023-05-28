export type diamondGovernanceJson = { [contractName: string]: { address: string } };

export type functionSelectorsJson = { [selector: string]: string };

export type variableSelectorsJson = { 
    [variableSelector: string]: { 
        facetName: string; 
        variableName: string; 
        variableType: string; 
        setSelector: string; 
    }
};
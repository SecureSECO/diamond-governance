export type DiamondGovernanceJson = { [contractName: string]: { address: string } };

export type FunctionSelectorsJson = { [selector: string]: string };

export type VariableSelectorsJson = { 
    [variableSelector: string]: { 
        facetName: string; 
        variableName: string; 
        variableType: string; 
        setSelector: string; 
    }
};
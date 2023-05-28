export type diamondGovernanceJson = { [contractName: string]: { address: string } };

export type functionSelectorsJson = { [selector: string]: string };

export type variableSelectorsJson = { 
    [facetSelector: string]: { 
        facetName: string; 
        variables: { 
            [variableSelector: string]: { 
                variableName: string; 
                variableType: string; 
                setSelector: string; 
            } 
        } 
    } 
};
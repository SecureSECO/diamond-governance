export const verificationContractAbi = [
  {
    inputs: [],
    name: "reverifyThreshold",
    outputs: [
      {
        internalType: "uint64",
        name: "",
        type: "uint64",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "_toCheck",
        type: "address",
      },
    ],
    name: "getStamps",
    outputs: [
      {
        components: [
          {
            internalType: "string",
            name: "providerId",
            type: "string",
          },
          {
            internalType: "string",
            name: "userHash",
            type: "string",
          },
          {
            internalType: "uint64[]",
            name: "verifiedAt",
            type: "uint64[]",
          },
        ],
        internalType: "struct GithubVerification.Stamp[]",
        name: "",
        type: "tuple[]",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "getThresholdHistory",
    outputs: [
      {
        components: [
          {
            internalType: "uint64",
            name: "timestamp",
            type: "uint64",
          },
          {
            internalType: "uint64",
            name: "threshold",
            type: "uint64",
          },
        ],
        internalType: "struct GithubVerification.Threshold[]",
        name: "",
        type: "tuple[]",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "string",
        name: "_providerId",
        type: "string",
      },
    ],
    name: "unverify",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "_toVerify",
        type: "address",
      },
      {
        internalType: "string",
        name: "_userHash",
        type: "string",
      },
      {
        internalType: "uint64",
        name: "_timestamp",
        type: "uint64",
      },
      {
        internalType: "string",
        name: "_providerId",
        type: "string",
      },
      {
        internalType: "bytes",
        name: "_proofSignature",
        type: "bytes",
      },
    ],
    name: "verifyAddress",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
];

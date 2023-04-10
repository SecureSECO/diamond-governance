// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";

import { ERC20OneTimeRewardFacet, ERC20OneTimeRewardFacetInit } from "./ERC20OneTimeRewardFacet.sol";

import { LibERC20OneTimeVerificationRewardStorage } from "../../../../../libraries/storage/LibERC20OneTimeVerificationRewardStorage.sol";

library ERC20OneTimeVerificationRewardFacetInit {
    struct InitParams {
        // Add a reward for every stamp? Or every stamp is rewarded the same?
        ERC20OneTimeRewardFacetInit.InitParams oneTimeRewardInit;
    }

    function init(InitParams calldata _params) external {
        ERC20OneTimeRewardFacetInit.init(_params.oneTimeRewardInit);
    }
}

contract ERC20OneTimeVerificationRewardFacet is ERC20OneTimeRewardFacet {
    // TODO
}
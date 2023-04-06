// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IDAO} from "@aragon/osx/core/plugin/Plugin.sol";
import {LibVerificationStorage} from "../../libraries/storage/LibVerificationStorage.sol";
import { ITieredMembershipStructure } from "../../facets/governance/structure/membership/ITieredMembershipStructure.sol";
import { AragonAuth } from "../../utils/AragonAuth.sol";
import { GithubVerification } from "../../verification/GithubVerification.sol";

library VerificationFacetInit {
    struct InitParams {
        address verificationContractAddress;
    }

    function init(InitParams calldata _params) external {
        LibVerificationStorage.getStorage().verificationContractAddress = _params.verificationContractAddress;
    }
}

contract VerificationFacet is ITieredMembershipStructure, AragonAuth {
    bytes32 public constant UPDATE_TIER_MAPPING_PERMISSION = keccak256("UPDATE_TIER_MAPPING_PERMISSION");

    function whitelist(address _address) internal {
        LibVerificationStorage.getStorage().whitelistTimestamps[_address] = uint64(block.timestamp);
    }

    function toAsciiString(address x) internal pure returns (string memory) {
        bytes memory s = new bytes(40);
        for (uint i = 0; i < 20; i++) {
            bytes1 b = bytes1(uint8(uint(uint160(x)) / (2 ** (8 * (19 - i)))));
            bytes1 hi = bytes1(uint8(b) / 16);
            bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
            s[2 * i] = char(hi);
            s[2 * i + 1] = char(lo);
        }
        return string(s);
    }

    function char(bytes1 b) internal pure returns (bytes1 c) {
        if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
        else return bytes1(uint8(b) + 0x57);
    }
    
    function getStampsAt(
        address _address,
        uint _timestamp
    ) public view returns (GithubVerification.Stamp[] memory) {
        LibVerificationStorage.Storage storage ds = LibVerificationStorage.getStorage();
        GithubVerification verificationContract = GithubVerification(ds.verificationContractAddress);
        GithubVerification.Stamp[] memory stamps = verificationContract.getStampsAt(
            _address,
            _timestamp
        );

        uint64 whitelistTimestamp = ds.whitelistTimestamps[_address];
        if (whitelistTimestamp == 0) {
            return stamps;
        } else {
            GithubVerification.Stamp[] memory stamps2 = new GithubVerification.Stamp[](
                stamps.length + 1
            );

            uint64[] memory verifiedAt = new uint64[](1);
            verifiedAt[0] = whitelistTimestamp;

            GithubVerification.Stamp memory stamp = GithubVerification.Stamp(
                "whitelist",
                toAsciiString(_address),
                verifiedAt
            );

            stamps2[0] = stamp;

            for (uint i = 0; i < stamps.length; i++) {
                stamps2[i + 1] = stamps[i];
            }

            return stamps2;
        }
    }

    /// @inheritdoc ITieredMembershipStructure
    function getMembers() external view virtual override returns (address[] memory members) {
        
    }

    /// @inheritdoc ITieredMembershipStructure
    /// @
    function getTierAt(address _account, uint256 _timestamp) public view virtual override returns (uint256) {
        GithubVerification.Stamp[] memory stampsAt = getStampsAt(_account, _timestamp);

        LibVerificationStorage.Storage storage ds = LibVerificationStorage.getStorage();
        mapping (string => uint256) storage tierMapping = ds.tierMapping;

        uint256 tier = 0;

        // Set highest tier score in stamps
        for (uint8 i = 0; i < stampsAt.length; i++) {
            uint256 currentTier = tierMapping[stampsAt[i].providerId];
            if (currentTier > tier)
                tier = currentTier;
        }

        return 3;
    }

    /// @notice Updates a "tier" score for a given provider. This can be used to either score new providers or update
    /// scores of already scored providers
    /// @dev This maps a providerId to a uint256 tier
    function updateTierMapping(string calldata providerId, uint256 tier) external {
        LibVerificationStorage.getStorage().tierMapping[providerId] = tier;
    }
}

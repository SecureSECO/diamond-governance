// SPDX-License-Identifier: MIT
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  */

pragma solidity ^0.8.0;

import {IDAO} from "@aragon/osx/core/plugin/Plugin.sol";
import {LibVerificationStorage} from "../../libraries/storage/LibVerificationStorage.sol";
import { ITieredMembershipStructure } from "../../facets/governance/structure/membership/ITieredMembershipStructure.sol";
import { AuthConsumer } from "../../utils/AuthConsumer.sol";
import { GithubVerification } from "../../verification/GithubVerification.sol";

// Used for diamond pattern storage
library VerificationFacetInit {
    struct InitParams {
        address verificationContractAddress;
        string[] providers;
        uint256[] rewards;
    }

    function init(InitParams calldata _params) external {
        LibVerificationStorage.Storage storage s = LibVerificationStorage.getStorage();

        s.verificationContractAddress = _params.verificationContractAddress;
        require(_params.providers.length == _params.rewards.length, "Providers and rewards array length does not match");
        for (uint i; i < _params.providers.length;) {
            s.tierMapping[_params.providers[i]] = _params.rewards[i];

            unchecked {
                i++;
            }
        }
    }
}

/// @title Verification facet for the Diamond Governance Plugin
/// @author J.S.C.L. & T.Y.M.W. @ UU
/// @notice Additionally to the verification functionality, this includes the whitelisting functionality for the DAO membership
contract VerificationFacet is ITieredMembershipStructure, AuthConsumer {
    // Permission used by the updateTierMapping function
    bytes32 public constant UPDATE_TIER_MAPPING_PERMISSION = keccak256("UPDATE_TIER_MAPPING_PERMISSION");

    /// @notice Whitelist a given account
    function whitelist(address _address) internal {
        LibVerificationStorage.getStorage().whitelistTimestamps[_address] = uint64(block.timestamp);
    }

    /// @notice Returns the given address as a string
    /// Source: https://ethereum.stackexchange.com/a/8447
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

    /// @notice Returns the ascii character related to a byte
    /// @dev Helper function for toAsciiString
    /// Source: https://ethereum.stackexchange.com/a/8447
    function char(bytes1 b) internal pure returns (bytes1 c) {
        if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
        else return bytes1(uint8(b) + 0x57);
    }
    
    /// @notice Returns stamps of an account at a given timestamp
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

        // Check if this account was whitelisted and add a "whitelist" stamp if applicable
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
        LibVerificationStorage.Storage storage ds = LibVerificationStorage.getStorage();
        GithubVerification verificationContract = GithubVerification(ds.verificationContractAddress);
        return verificationContract.getAllMembers();
    }

    /// @inheritdoc ITieredMembershipStructure
    /// @notice Returns the highest tier included in the stamps of a given account
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

        return tier;
    }

    /// @notice Updates a "tier" score for a given provider. This can be used to either score new providers or update
    /// scores of already scored providers
    /// @dev This maps a providerId to a uint256 tier
    function updateTierMapping(string calldata providerId, uint256 tier) external {
        LibVerificationStorage.getStorage().tierMapping[providerId] = tier;
    }
}

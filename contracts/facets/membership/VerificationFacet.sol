// SPDX-License-Identifier: MIT
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  */

pragma solidity ^0.8.0;

import {IDAO} from "@aragon/osx/core/plugin/Plugin.sol";
import {LibVerificationStorage} from "../../libraries/storage/LibVerificationStorage.sol";
import { ITieredMembershipStructure, IMembershipExtended, IMembership } from "../../facets/governance/structure/membership/ITieredMembershipStructure.sol";
import { IMembershipWhitelisting } from "../../facets/governance/structure/membership/IMembershipWhitelisting.sol";
import { AuthConsumer } from "../../utils/AuthConsumer.sol";
import { IVerificationFacet, SignVerification } from "./IVerificationFacet.sol";
import { IFacet } from "../IFacet.sol";

/**
 * @title VerificationFacet
 * @author Utrecht University
 * @notice Implementation of ITieredMembershipStructure, IMembershipWhitelisting and IVerificationFacet.
 */
contract VerificationFacet is ITieredMembershipStructure, IMembershipWhitelisting, IVerificationFacet, AuthConsumer, IFacet {
    // Permission used by the updateTierMapping function
    bytes32 public constant UPDATE_TIER_MAPPING_PERMISSION_ID = keccak256("UPDATE_TIER_MAPPING_PERMISSION");
    // Permission used by the whitelist function
    bytes32 public constant WHITELIST_MEMBER_PERMISSION_ID = keccak256("WHITELIST_MEMBER_PERMISSION");
    // Permission used to update the verification contract address
    bytes32 public constant UPDATE_VERIFICATION_CONTRACT_PERMISSION_ID = keccak256("UPDATE_VERIFICATION_CONTRACT_PERMISSION");
    // Permission used to update the verification day threshold
    bytes32 public constant UPDATE_VERIFY_DAY_THRESHOLD_PERMISSION_ID = keccak256("UPDATE_VERIFY_DAY_THRESHOLD_PERMISSION");
    // Permission used to update the reverification day threshold
    bytes32 public constant UPDATE_REVERIFICATION_THRESHOLD_PERMISSION_ID = keccak256("UPDATE_REVERIFICATION_THRESHOLD_PERMISSION");

    struct VerificationFacetInitParams {
        address verificationContractAddress;
        string[] providers;
        uint256[] rewards;
    }

    /// @inheritdoc IFacet
    function init(bytes memory _initParams) public virtual override {
        VerificationFacetInitParams memory _params = abi.decode(_initParams, (VerificationFacetInitParams));
        __VerificationFacet_init(_params);
    }

    function __VerificationFacet_init(VerificationFacetInitParams memory _params) public virtual {
        LibVerificationStorage.Storage storage s = LibVerificationStorage.getStorage();

        s.verificationContractAddress = _params.verificationContractAddress;
        require(_params.providers.length == _params.rewards.length, "Providers and rewards array length does not match");
        for (uint i; i < _params.providers.length;) {
            s.tierMapping[_params.providers[i]] = _params.rewards[i];

            unchecked {
                i++;
            }
        }

        registerInterface(type(IMembership).interfaceId);
        registerInterface(type(IMembershipExtended).interfaceId);
        registerInterface(type(ITieredMembershipStructure).interfaceId);
        registerInterface(type(IMembershipWhitelisting).interfaceId);
        registerInterface(type(IVerificationFacet).interfaceId);
        
        emit MembershipContractAnnounced(address(this));
    }
    
    /// @inheritdoc IFacet
    function deinit() public virtual override {
        unregisterInterface(type(IMembership).interfaceId);
        unregisterInterface(type(IMembershipExtended).interfaceId);
        unregisterInterface(type(ITieredMembershipStructure).interfaceId);
        unregisterInterface(type(IMembershipWhitelisting).interfaceId);
        unregisterInterface(type(IVerificationFacet).interfaceId);
        super.deinit();
    }

    /// @notice Whitelist a given account
    /// @inheritdoc IMembershipWhitelisting
    function whitelist(address _address) external virtual override auth(WHITELIST_MEMBER_PERMISSION_ID) {
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
    
    /// @inheritdoc IVerificationFacet
    function getStampsAt(
        address _address,
        uint _timestamp
    ) public view virtual override returns (SignVerification.Stamp[] memory) {
        LibVerificationStorage.Storage storage ds = LibVerificationStorage.getStorage();
        SignVerification verificationContract = SignVerification(ds.verificationContractAddress);
        SignVerification.Stamp[] memory stamps = verificationContract.getStampsAt(
            _address,
            _timestamp
        );

        // Check if this account was whitelisted and add a "whitelist" stamp if applicable
        uint64 whitelistTimestamp = ds.whitelistTimestamps[_address];
        if (whitelistTimestamp == 0) {
            return stamps;
        } else {
            SignVerification.Stamp[] memory stamps2 = new SignVerification.Stamp[](
                stamps.length + 1
            );

            uint64[] memory verifiedAt = new uint64[](1);
            verifiedAt[0] = whitelistTimestamp;

            SignVerification.Stamp memory stamp = SignVerification.Stamp(
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

    /// @inheritdoc IVerificationFacet
    function getStamps(address _address) external view override returns (SignVerification.Stamp[] memory) {
        LibVerificationStorage.Storage storage ds = LibVerificationStorage.getStorage();
        SignVerification verificationContract = SignVerification(ds.verificationContractAddress);
        SignVerification.Stamp[] memory stamps = verificationContract.getStamps(_address);

        // Check if this account was whitelisted and add a "whitelist" stamp if applicable
        uint64 whitelistTimestamp = ds.whitelistTimestamps[_address];
        if (whitelistTimestamp == 0) {
            return stamps;
        } else {
            SignVerification.Stamp[] memory stamps2 = new SignVerification.Stamp[](
                stamps.length + 1
            );

            uint64[] memory verifiedAt = new uint64[](1);
            verifiedAt[0] = whitelistTimestamp;

            SignVerification.Stamp memory stamp = SignVerification.Stamp(
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
        SignVerification verificationContract = SignVerification(ds.verificationContractAddress);
        return verificationContract.getAllMembers();
    }

    /// @inheritdoc ITieredMembershipStructure
    /// @notice Returns the highest tier included in the stamps of a given account
    function getTierAt(address _account, uint256 _timestamp) public view virtual override returns (uint256) {
        SignVerification.Stamp[] memory stampsAt = getStampsAt(_account, _timestamp);

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

    /// @inheritdoc IVerificationFacet
    function getTierMapping(string calldata _providerId) external view virtual override returns (uint256) {
        return LibVerificationStorage.getStorage().tierMapping[_providerId];
    }

    /// @inheritdoc IVerificationFacet
    function setTierMapping(string calldata _providerId, uint256 _tier) external virtual override auth(UPDATE_TIER_MAPPING_PERMISSION_ID) {
        LibVerificationStorage.getStorage().tierMapping[_providerId] = _tier;
    }

    /// @inheritdoc IVerificationFacet
    function getVerificationContractAddress() external view virtual override returns (address) {
        return LibVerificationStorage.getStorage().verificationContractAddress;
    }

    /// @inheritdoc IVerificationFacet
    function setVerificationContractAddress(address _verificationContractAddress) external virtual override auth(UPDATE_VERIFICATION_CONTRACT_PERMISSION_ID) {
        LibVerificationStorage.getStorage().verificationContractAddress = _verificationContractAddress; 
    }

    /// @inheritdoc IVerificationFacet
    function getVerifyDayThreshold() external view returns (uint64) {
        SignVerification verificationContract = SignVerification(LibVerificationStorage.getStorage().verificationContractAddress);
        return verificationContract.getVerifyDayThreshold();
    }

    /// @inheritdoc IVerificationFacet
    function setVerifyDayThreshold(uint64 _verifyDayThreshold) external auth(UPDATE_VERIFY_DAY_THRESHOLD_PERMISSION_ID) {
        SignVerification verificationContract = SignVerification(LibVerificationStorage.getStorage().verificationContractAddress);
        verificationContract.setVerifyDayThreshold(_verifyDayThreshold);
    }

    /// @inheritdoc IVerificationFacet
    function getReverifyThreshold() external view returns (uint64) {
        SignVerification verificationContract = SignVerification(LibVerificationStorage.getStorage().verificationContractAddress);
        return verificationContract.getReverifyThreshold();
    }

    /// @inheritdoc IVerificationFacet
    function setReverifyThreshold(uint64 _reverifyThreshold) external auth(UPDATE_REVERIFICATION_THRESHOLD_PERMISSION_ID) {
        SignVerification verificationContract = SignVerification(LibVerificationStorage.getStorage().verificationContractAddress);
        verificationContract.setReverifyThreshold(_reverifyThreshold);
    }
}

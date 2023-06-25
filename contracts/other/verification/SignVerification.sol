// SPDX-License-Identifier: MIT
/**
 * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
 * © Copyright Utrecht University (Department of Information and Computing Sciences)
 */

pragma solidity ^0.8.0;

import {GenericSignatureHelper} from "../../utils/GenericSignatureHelper.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title SignVerification
 * @author Utrecht University
 * @notice This contracat requires a signer to provide proof of verification with a certain offchain service (example: GitHub) and assigns the respecitve stamp to the address.
 */
contract SignVerification is GenericSignatureHelper, Ownable {
    // Map from user to their stamps
    mapping(address => Stamp[]) internal stamps;
    // Map from userhash to address to make sure the userhash isn't already used by another address
    mapping(string => address) internal stampHashMap;
    // Map to show if an address has ever been verified
    mapping(address => bool) internal isMember;
    address[] allMembers;

    /// @notice The thresholdHistory array stores the history of the verifyDayThreshold variable. This is needed because we might want to check if some stamps were valid in the past.
    Threshold[] thresholdHistory;

    /// @notice The reverifyThreshold determines how long a user has to wait before they can re-verify their address, in days
    uint64 reverifyThreshold;

    /// @notice A stamp defines proof of verification for a user on a specific platform at a specific date
    struct Stamp {
        string providerId; // Unique id for the provider (github, proofofhumanity, etc.)
        string userHash; // Hash of some unique user data of the provider (username, email, etc.)
        uint64[] verifiedAt; // Timestamps at which the user has verified
    }

    /// @notice A threshold defines the number of days for which a stamp is valid
    struct Threshold {
        uint64 timestamp; // Timestamp at which the threshold was set
        uint64 threshold; // Number of days for which a stamp is valid
    }

    /// @notice Initializes the owner of the contract
    constructor(uint64 _threshold, uint64 _reverifyThreshold) {
        thresholdHistory.push(Threshold(uint64(block.timestamp), _threshold));
        reverifyThreshold = _reverifyThreshold;
    }

    /// @notice This function can only be called by the owner, and it verifies an address. It's not possible to re-verify an address before half the verifyDayThreshold has passed.
    /// @dev Verifies an address
    /// @param _toVerify The address to verify
    /// @param _timestamp in seconds
    function verifyAddress(
        address _toVerify,
        string calldata _userHash,
        uint64 _timestamp,
        string calldata _providerId,
        bytes calldata _proofSignature
    ) external {
        require(
            stampHashMap[_userHash] == address(0) ||
                stampHashMap[_userHash] == _toVerify,
            "ID already affiliated with another address"
        );

        require(_toVerify != address(0), "Address cannot be 0x0");
        require(
            block.timestamp < _timestamp + 1 hours,
            "Proof expired, try verifying again"
        );

        require(
            verify(owner(), keccak256(abi.encodePacked(_toVerify, _userHash, uint(_timestamp), _providerId)), _proofSignature),
            "Proof is not valid"
        );

        // Check if there is existing stamp with providerId
        bool found; // = false;
        uint foundIndex; // = 0;

        for (uint i; i < stamps[_toVerify].length; ) {
            if (
                keccak256(abi.encodePacked(stamps[_toVerify][i].providerId)) ==
                keccak256(abi.encodePacked(_providerId))
            ) {
                found = true;
                foundIndex = i;
                break;
            }

            unchecked {
                i++;
            }
        }

        if (!found) {
            // Check if this is the first time this user has verified so we can add them to the allMembers list
            if (!isMember[_toVerify]) {
                isMember[_toVerify] = true;
                allMembers.push(_toVerify);
            }

            // Create new stamp if user does not already have a stamp for this providerId
            stamps[_toVerify].push(
                createStamp(_providerId, _userHash, _timestamp)
            );

            // This only needs to happens once (namely the first time an account verifies)
            stampHashMap[_userHash] = _toVerify;
        } else {
            // If user already has a stamp for this providerId
            // Check how long it has been since the last verification
            uint64[] storage verifiedAt = stamps[_toVerify][foundIndex]
                .verifiedAt;
            uint64 timeSinceLastVerification = uint64(block.timestamp) -
                verifiedAt[verifiedAt.length - 1];

            // If it has been more than reverifyThreshold days, update the stamp
            if (timeSinceLastVerification > reverifyThreshold) {
                // Overwrite the userHash (in case the user changed their username or used another account to reverify)
                stamps[_toVerify][foundIndex].userHash = _userHash;
                verifiedAt.push(_timestamp);
            } else {
                revert(
                    "Address already verified; cannot re-verify yet, wait at least half the verifyDayThreshold"
                );
            }
        }
    }

    /// @notice Unverifies a provider from the sender
    /// @param _providerId Unique id for the provider (github, proofofhumanity, etc.) to be removed
    function unverify(string calldata _providerId) external {
        // Assume all is good in the world
        Stamp[] storage stampsAt = stamps[msg.sender];

        // Look up the corresponding stamp for the provider
        for (uint i; i < stampsAt.length; ) {
            if (stringsAreEqual(stampsAt[i].providerId, _providerId)) {
                // Remove the mapping from userhash to address
                stampHashMap[stampsAt[i].userHash] = address(0);

                // Remove stamp from stamps array (we don't care about order so we can just swap and pop)
                stampsAt[i] = stampsAt[stampsAt.length - 1];
                stampsAt.pop();
                return;
            }

            unchecked {
                i++;
            }
        }

        revert(
            "Could not find this provider among your stamps; are you sure you're verified with this provider?"
        );
    }

    /// @dev Solidity doesn't support string comparison, so we use keccak256 to compare strings
    function stringsAreEqual(
        string memory str1,
        string memory str2
    ) internal pure returns (bool) {
        return
            keccak256(abi.encodePacked(str1)) ==
            keccak256(abi.encodePacked(str2));
    }

    /// @notice Creates a stamp for a user
    /// @param _providerId Unique id for the provider (github, proofofhumanity, etc.)
    /// @param _userHash Unique user hash on the platform of the stamp (GH, PoH, etc.)
    /// @param _timestamp Timestamp at which the proof was generated
    /// @return Stamp Returns the created stamp
    function createStamp(
        string memory _providerId,
        string memory _userHash,
        uint64 _timestamp
    ) internal returns (Stamp memory) {
        uint64[] memory verifiedAt = new uint64[](1);
        verifiedAt[0] = _timestamp;
        Stamp memory stamp = Stamp(_providerId, _userHash, verifiedAt);
        stampHashMap[_userHash] = msg.sender;
        return stamp;
    }

    /// @notice This function returns the stamps of an address
    /// @param _toCheck The address to check
    /// @return An array of stamps
    function getStamps(
        address _toCheck
    ) external view returns (Stamp[] memory) {
        return stamps[_toCheck];
    }

    /// @notice Returns the *valid* stamps of an address at a specific timestamp
    /// @param _toCheck The address to check
    /// @param _timestamp The timestamp to check (seconds)
    function getStampsAt(
        address _toCheck,
        uint _timestamp
    ) external view returns (Stamp[] memory) {
        Stamp[] memory stampsAt = new Stamp[](stamps[_toCheck].length);
        uint count; // = 0;

        // Loop through all the user's stamps
        for (uint i; i < stamps[_toCheck].length; ) {
            // Get the list of all verification timestamps
            uint64[] storage verifiedAt = stamps[_toCheck][i].verifiedAt;

            // Get the threshold at _timestamp
            uint currentTimestampIndex = thresholdHistory.length - 1;
            while (
                currentTimestampIndex > 0 &&
                thresholdHistory[currentTimestampIndex].timestamp > _timestamp
            ) {
                currentTimestampIndex--;
            }

            uint64 verifyDayThreshold = thresholdHistory[currentTimestampIndex]
                .threshold;

            // Reverse for loop, because more recent dates are at the end of the array
            for (uint j = verifiedAt.length; j > 0; j--) {
                // If the stamp is valid at _timestamp, add it to the stampsAt array
                if (
                    verifiedAt[j - 1] + (verifyDayThreshold * 1 days) >
                    _timestamp &&
                    verifiedAt[j - 1] < _timestamp
                ) {
                    stampsAt[count] = stamps[_toCheck][i];
                    count++;
                    break;
                } else if (
                    verifiedAt[j - 1] + (verifyDayThreshold * 1 days) <
                    _timestamp
                ) {
                    break;
                }
            }

            unchecked {
                i++;
            }
        }

        Stamp[] memory stampsAtTrimmed = new Stamp[](count);

        for (uint i = 0; i < count; i++) {
            stampsAtTrimmed[i] = stampsAt[i];
        }

        return stampsAtTrimmed;
    }

    function getAllMembers() external view returns (address[] memory) {
        return allMembers;
    }

    /// @notice Returns whether or not the caller is or was a member at any time
    /// @dev Loop through the array of all members and return true if the caller is found
    /// @return bool Whether or not the caller is or was a member at any time
    function isOrWasMember(address _toCheck) external view returns (bool) {
        return isMember[_toCheck];
    }

    /// @notice Returns latest verifyDayThreshold
    function getVerifyDayThreshold() external view returns (uint64) {
        return thresholdHistory[thresholdHistory.length - 1].threshold;
    }

    /// @notice This function can only be called by the owner to set the verifyDayThreshold
    /// @dev Sets the verifyDayThreshold
    /// @param _days The number of days to set the verifyDayThreshold to
    function setVerifyDayThreshold(uint64 _days) external onlyOwner {
        Threshold memory lastThreshold = thresholdHistory[
            thresholdHistory.length - 1
        ];
        require(
            lastThreshold.threshold != _days,
            "Threshold already set to this value"
        );

        thresholdHistory.push(Threshold(uint64(block.timestamp), _days));
    }

    /// @notice Returns the reverifyThreshold
    function getReverifyThreshold() external view returns (uint64) {
        return reverifyThreshold;
    }

    /// @notice This function can only be called by the owner to set the reverifyThreshold
    /// @dev Sets the reverifyThreshold
    /// @param _days The number of days to set the reverifyThreshold to
    function setReverifyThreshold(uint64 _days) external onlyOwner {
        reverifyThreshold = _days;
    }

    /// @notice Returns the full threshold history
    /// @return An array of Threshold structs
    function getThresholdHistory() external view returns (Threshold[] memory) {
        return thresholdHistory;
    }

}
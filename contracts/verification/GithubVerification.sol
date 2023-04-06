// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SignatureHelper.sol";

error InvalidProof(string signature);

/// @title A contract to verify addresses
/// @author JSC LEE
/// @notice You can use this contract to verify addresses
contract GithubVerification is SignatureHelper {
    mapping(address => Stamp[]) internal stamps;
    mapping(string => address) internal stampHashMap;
    Threshold[] thresholdHistory;

    address private immutable _owner;

    // A stamp defines proof of verification for a user on a specific platform at a specific date
    struct Stamp {
        string providerId;
        string _hash;
        uint64[] verifiedAt;
    }

    struct Threshold {
        uint64 timestamp;
        uint64 threshold;
    }

    /// @notice This constructor sets the owner of the contract
    constructor (uint64 _threshold) {
        thresholdHistory.push(Threshold(uint64(block.timestamp), _threshold));
        _owner = msg.sender;
    }

    /// @notice This function can only be called by the owner, and it verifies an address. It's not possible to re-verofuy an address before half the verifyDayThreshold has passed.
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
            verify(_owner, _toVerify, _userHash, _timestamp, _proofSignature),
            "Proof is not valid"
        );

        // Check if there is existing stamp with providerId
        bool found = false;
        uint foundIndex = 0;

        for (uint i = 0; i < stamps[_toVerify].length; i++) {
            if (
                keccak256(abi.encodePacked(stamps[_toVerify][i].providerId)) ==
                keccak256(abi.encodePacked(_providerId))
            ) {
                found = true;
                foundIndex = i;
                break;
            }
        }

        if (!found) {
            // Create new stamp if user does not already have a stamp for this providerId
            stamps[_toVerify].push(createStamp(_providerId, _userHash, _timestamp));
        } else { // If user already has a stamp for this providerId
            // Check how long it has been since the last verification
            uint64[] storage verifiedAt = stamps[_toVerify][foundIndex].verifiedAt;
            uint64 timeSinceLastVerification = uint64(block.timestamp) -
                verifiedAt[verifiedAt.length - 1];

            // If it has been more than (verifyDayThreshold / 2) days, update the stamp
            if (timeSinceLastVerification > uint64((thresholdHistory[thresholdHistory.length - 1].threshold / 2) * 1 days)) {
                verifiedAt.push(_timestamp);
            } else {
                revert(
                    "Address already verified; cannot re-verify yet, wait at least half the verifyDayThreshold"
                );
            }
        }

        stampHashMap[_userHash] = _toVerify;
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

    /// @notice This function checks if an address is verified and if the address has been verified recently (within the set verifyDayThreshold)
    /// @param _toCheck The address to check
    /// @return A boolean indicating if the address is verified
    // function addressIsVerified(address _toCheck) external view returns (bool) {
    //     if (
    //         verifiedTimeMap[_toCheck] + (verifyDayThreshold * 1 days) <
    //         block.timestamp
    //     ) return false;

    //     return verifiedTimeMap[_toCheck] > 0;
    // }

    /// @notice This function returns the stamps of an address
    /// @param _toCheck The address to check
    /// @return An array of stamps
    function getStamps(
        address _toCheck
    ) external view returns (Stamp[] memory) {
        return stamps[_toCheck];
    }


    function getStampsAt(
        address _toCheck,
        uint _timestamp
    ) external view returns (Stamp[] memory) {
        Stamp[] memory stampsAt = new Stamp[](stamps[_toCheck].length);
        uint count = 0;

        // Loop through stamps
        for (uint i = 0; i < stamps[_toCheck].length; i++) {
            uint64[] storage verifiedAt = stamps[_toCheck][i].verifiedAt;
            uint currentTimestampIndex = thresholdHistory.length - 1;

            // Reverse for loop, because more recent dates are at the end of the array
            for (uint j = verifiedAt.length; j > 0; j--) {
                while (currentTimestampIndex > 0 && verifiedAt[j - 1] < thresholdHistory[currentTimestampIndex].threshold) {
                    currentTimestampIndex--;
                }
                
                uint64 verifyDayThreshold = thresholdHistory[currentTimestampIndex].threshold;

                // Check if the verification timestamp is within the verifyDayThreshold
                if (verifiedAt[j - 1] + (verifyDayThreshold * 1 days) > _timestamp 
                    && verifiedAt[j - 1] < _timestamp) {
                    stampsAt[count] = stamps[_toCheck][i];
                    count++;
                    break;
                } else if (verifiedAt[j - 1] + (verifyDayThreshold * 1 days) < _timestamp) {
                    break;
                }
            }
        }

        Stamp[] memory stampsAtTrimmed = new Stamp[](count);

        for (uint i = 0; i < count; i++) {
            stampsAtTrimmed[i] = stampsAt[i];
        }

        return stampsAtTrimmed;
    }
    
    /// @notice This function can only be called by the owner to set the verifyDayThreshold
    /// @dev Sets the verifyDayThreshold
    /// @param _days The number of days to set the verifyDayThreshold to
    function setVerifyDayThreshold(uint64 _days) external onlyOwner {
        Threshold memory lastThreshold = thresholdHistory[thresholdHistory.length - 1];
        require(lastThreshold.threshold != _days, "Threshold already set to this value");
        
        thresholdHistory.push(Threshold(uint64(block.timestamp), _days));
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "Ownable: caller is not the owner");
        _;
    }
}

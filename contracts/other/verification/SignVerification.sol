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

    /// @notice The thresholdHistory array stores the history of the verifyThreshold variable. This is needed because we might want to check if some stamps were valid in the past.
    Threshold[] thresholdHistory;

    /// @notice The reverifyThreshold determines how long a user has to wait before they can re-verify their address, in days
    uint reverifyThreshold;

    /// @notice The signer is the address that can sign proofs of verification
    address _signer;

    /// @notice A stamp defines proof of verification for a user on a specific platform at a specific date
    struct Stamp {
        string providerId; // Unique id for the provider (github, proofofhumanity, etc.)
        string userHash; // Hash of some unique user data of the provider (username, email, etc.)
        uint[] verifiedAt; // Block number at which the user has verified
    }

    /// @notice A threshold defines the number of days for which a stamp is valid
    struct Threshold {
        uint blockNumber; // Block number at which the threshold was set
        uint threshold; // Number of blocks for which a stamp is valid
    }

    /// @notice Initializes the owner of the contract
    constructor(uint _threshold, uint _reverifyThreshold, address signer_) {
        thresholdHistory.push(Threshold(block.number, _threshold));
        reverifyThreshold = _reverifyThreshold;
        _signer = signer_;
    }

    /// @notice This function can only be called by the owner, and it verifies an address. It's not possible to re-verify an address before half the verifyThreshold has passed.
    /// @dev Verifies an address
    /// @param _toVerify The address to verify
    /// @param _userHash The hash of the user's unique data on the provider (username, email, etc.)
    /// @param _timestamp The block number at which the proof was generated
    /// @param _providerId Unique id for the provider (github, proofofhumanity, etc.)
    /// @param _proofSignature The proof signed by the server
    function verifyAddress(
        address _toVerify,
        string calldata _userHash,
        uint _timestamp,
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
            verify(_signer, keccak256(abi.encodePacked(_toVerify, _userHash, _timestamp, _providerId)), _proofSignature),
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
                createStamp(_providerId, _userHash, block.number)
            );

            // This only needs to happens once (namely the first time an account verifies)
            stampHashMap[_userHash] = _toVerify;
        } else {
            // If user already has a stamp for this providerId
            // Check how long it has been since the last verification
            uint[] storage verifiedAt = stamps[_toVerify][foundIndex]
                .verifiedAt;
            uint blocksSinceLastVerification = block.number -
                verifiedAt[verifiedAt.length - 1];

            // If it has been more than reverifyThreshold days, update the stamp
            if (blocksSinceLastVerification > reverifyThreshold) {
                // Overwrite the userHash (in case the user changed their username or used another account to reverify)
                stamps[_toVerify][foundIndex].userHash = _userHash;
                verifiedAt.push(block.number);
            } else {
                revert(
                    "Address already verified; cannot re-verify yet, wait at least half the verifyThreshold"
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
    /// @param _blockNumber Block number at which the proof was submitted
    /// @return Stamp Returns the created stamp
    function createStamp(
        string memory _providerId,
        string memory _userHash,
        uint _blockNumber
    ) internal returns (Stamp memory) {
        uint[] memory verifiedAt = new uint[](1);
        verifiedAt[0] = _blockNumber;
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

    /// @notice Returns the *valid* stamps of an address at a specific block number
    /// @param _toCheck The address to check
    /// @param _blockNumber The block number to check
    function getStampsAt(
        address _toCheck,
        uint _blockNumber
    ) external view returns (Stamp[] memory) {
        Stamp[] memory stampsAt = new Stamp[](stamps[_toCheck].length);
        uint count; // = 0;

        // Loop through all the user's stamps
        for (uint i; i < stamps[_toCheck].length; ) {
            // Get the list of all verification block numbers
            uint[] storage verifiedAt = stamps[_toCheck][i].verifiedAt;

            // Get the threshold at _blockNumber
            uint currentBlockNumberIndex = thresholdHistory.length - 1;
            while (
                currentBlockNumberIndex > 0 &&
                thresholdHistory[currentBlockNumberIndex].blockNumber > _blockNumber
            ) {
                currentBlockNumberIndex--;
            }

            uint verifyThreshold = thresholdHistory[currentBlockNumberIndex]
                .threshold;

            // Reverse for loop, because more recent dates are at the end of the array
            for (uint j = verifiedAt.length; j > 0; j--) {
                // If the stamp is valid at _blockNumber, add it to the stampsAt array
                if (
                    verifiedAt[j - 1] + verifyThreshold >
                    _blockNumber &&
                    verifiedAt[j - 1] < _blockNumber
                ) {
                    stampsAt[count] = stamps[_toCheck][i];
                    count++;
                    break;
                } else if (
                    verifiedAt[j - 1] + verifyThreshold <
                    _blockNumber
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

    /// @notice Returns latest verifyThreshold
    function getVerifyThreshold() external view returns (uint) {
        return thresholdHistory[thresholdHistory.length - 1].threshold;
    }

    /// @notice This function can only be called by the owner to set the verifyThreshold
    /// @dev Sets the verifyThreshold
    /// @param _blocks The number of blocks to set the verifyThreshold to
    function setVerifyThreshold(uint _blocks) external onlyOwner {
        Threshold memory lastThreshold = thresholdHistory[
            thresholdHistory.length - 1
        ];
        require(
            lastThreshold.threshold != _blocks,
            "Threshold already set to this value"
        );

        thresholdHistory.push(Threshold(block.number, _blocks));
    }

    /// @notice Returns the reverifyThreshold
    function getReverifyThreshold() external view returns (uint) {
        return reverifyThreshold;
    }

    /// @notice This function can only be called by the owner to set the reverifyThreshold
    /// @dev Sets the reverifyThreshold
    /// @param _days The number of days to set the reverifyThreshold to
    function setReverifyThreshold(uint _days) external onlyOwner {
        reverifyThreshold = _days;
    }

    /// @notice Returns the full threshold history
    /// @return An array of Threshold structs
    function getThresholdHistory() external view returns (Threshold[] memory) {
        return thresholdHistory;
    }

    /// @notice Sets the signer address
    /// @param signer_ new signer address
    function setSigner(address signer_) external onlyOwner {
        _signer = signer_;
    }

    /// @notice Returns the signer address
    /// @return Signer address
    function getSigner() external view returns (address) {
        return _signer;
    }

}

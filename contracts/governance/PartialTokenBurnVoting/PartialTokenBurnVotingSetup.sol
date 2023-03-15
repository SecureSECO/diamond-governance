// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.8.17;

import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {ERC165Checker} from "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
import {IERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import {IVotesUpgradeable} from "@openzeppelin/contracts-upgradeable/governance/utils/IVotesUpgradeable.sol";

import {IDAO} from "@aragon/osx/core/dao/IDAO.sol";
import {DAO} from "@aragon/osx/core/dao/DAO.sol";
import {PermissionLib} from "@aragon/osx/core/permission/PermissionLib.sol";
import {PluginSetup, IPluginSetup} from "@aragon/osx/framework/plugin/setup/PluginSetup.sol";
import {GovernanceERC20} from "@aragon/osx/token/ERC20/governance/GovernanceERC20.sol";

import {PartialVotingBase} from "../PartialVotingBase.sol";
import {PartialTokenBurnVoting} from "./PartialTokenBurnVoting.sol";
import {NonTransferableGovernanceERC20} from "../../token/NonTransferableGovernanceERC20.sol";

/// @title PartialTokenBurnVotingSetup
/// @author Utrecht University - 2023
/// @notice The setup contract of the `PartialTokenBurnVoting` plugin.
contract PartialTokenBurnVotingSetup is PluginSetup {
    using Address for address;
    using Clones for address;
    using ERC165Checker for address;

    /// @notice The address of the `PartialTokenBurnVoting` base contract.
    PartialTokenBurnVoting private immutable partialTokenBurnVotingBase;

    /// @notice The address of the `GovernanceERC20` base contract.
    address public immutable governanceERC20Base;

    /// @notice The token settings struct.
    /// @param name The token name. This parameter is only relevant if the token address is `address(0)`.
    /// @param symbol The token symbol. This parameter is only relevant if the token address is `address(0)`.
    struct TokenSettings {
        string name;
        string symbol;
    }

    /// @notice Thrown if passed helpers array is of worng length.
    /// @param length The array length of passed helpers.
    error WrongHelpersArrayLength(uint256 length);

    /// @notice The contract constructor, that deployes the bases.
    constructor() {
        governanceERC20Base = address(
            new NonTransferableGovernanceERC20(
                IDAO(address(0)),
                "",
                "",
                GovernanceERC20.MintSettings(new address[](0), new uint256[](0))
            )
        );
        partialTokenBurnVotingBase = new PartialTokenBurnVoting();
    }

    /// @inheritdoc IPluginSetup
    function prepareInstallation(
        address _dao,
        bytes calldata _data
    ) external returns (address plugin, PreparedSetupData memory preparedSetupData) {
        // Decode `_data` to extract the params needed for deploying and initializing `TokenVoting` plugin,
        // and the required helpers
        (
            PartialVotingBase.VotingSettings memory votingSettings,
            TokenSettings memory tokenSettings,
            // only used for GovernanceERC20(token is not passed)
            GovernanceERC20.MintSettings memory mintSettings
        ) = abi.decode(
                _data,
                (PartialVotingBase.VotingSettings, TokenSettings, GovernanceERC20.MintSettings)
            );

        // Prepare helpers.
        address[] memory helpers = new address[](1);

        // Clone a `GovernanceERC20`.
        address token = governanceERC20Base.clone();
        NonTransferableGovernanceERC20(token).initialize(
            IDAO(_dao),
            tokenSettings.name,
            tokenSettings.symbol,
            mintSettings
        );

        helpers[0] = token;

        // Prepare and deploy plugin proxy.
        plugin = createERC1967Proxy(
            address(partialTokenBurnVotingBase),
            abi.encodeWithSelector(PartialTokenBurnVoting.initialize.selector, _dao, votingSettings, token)
        );

        // Prepare permissions
        PermissionLib.MultiTargetPermission[]
            memory permissions = new PermissionLib.MultiTargetPermission[](4);

        // Set plugin permissions to be granted.
        // Grant the list of prmissions of the plugin to the DAO.
        permissions[0] = PermissionLib.MultiTargetPermission(
            PermissionLib.Operation.Grant,
            plugin,
            _dao,
            PermissionLib.NO_CONDITION,
            partialTokenBurnVotingBase.UPDATE_VOTING_SETTINGS_PERMISSION_ID()
        );

        permissions[1] = PermissionLib.MultiTargetPermission(
            PermissionLib.Operation.Grant,
            plugin,
            _dao,
            PermissionLib.NO_CONDITION,
            partialTokenBurnVotingBase.UPGRADE_PLUGIN_PERMISSION_ID()
        );

        // Grant `EXECUTE_PERMISSION` of the DAO to the plugin.
        permissions[2] = PermissionLib.MultiTargetPermission(
            PermissionLib.Operation.Grant,
            _dao,
            plugin,
            PermissionLib.NO_CONDITION,
            DAO(payable(_dao)).EXECUTE_PERMISSION_ID()
        );

        bytes32 tokenMintPermission = NonTransferableGovernanceERC20(token).MINT_PERMISSION_ID();
        permissions[3] = PermissionLib.MultiTargetPermission(
            PermissionLib.Operation.Grant,
            token,
            _dao,
            PermissionLib.NO_CONDITION,
            tokenMintPermission
        );

        preparedSetupData.helpers = helpers;
        preparedSetupData.permissions = permissions;
    }

    /// @inheritdoc IPluginSetup
    function prepareUninstallation(
        address _dao,
        SetupPayload calldata _payload
    ) external view returns (PermissionLib.MultiTargetPermission[] memory permissions) {
        // Prepare permissions.
        uint256 helperLength = _payload.currentHelpers.length;
        if (helperLength != 1) {
            revert WrongHelpersArrayLength({length: helperLength});
        }

        address token = _payload.currentHelpers[0];

        permissions = new PermissionLib.MultiTargetPermission[](4);

        // Set permissions to be Revoked.
        permissions[0] = PermissionLib.MultiTargetPermission(
            PermissionLib.Operation.Revoke,
            _payload.plugin,
            _dao,
            PermissionLib.NO_CONDITION,
            partialTokenBurnVotingBase.UPDATE_VOTING_SETTINGS_PERMISSION_ID()
        );

        permissions[1] = PermissionLib.MultiTargetPermission(
            PermissionLib.Operation.Revoke,
            _payload.plugin,
            _dao,
            PermissionLib.NO_CONDITION,
            partialTokenBurnVotingBase.UPGRADE_PLUGIN_PERMISSION_ID()
        );

        permissions[2] = PermissionLib.MultiTargetPermission(
            PermissionLib.Operation.Revoke,
            _dao,
            _payload.plugin,
            PermissionLib.NO_CONDITION,
            DAO(payable(_dao)).EXECUTE_PERMISSION_ID()
        );

        permissions[3] = PermissionLib.MultiTargetPermission(
            PermissionLib.Operation.Revoke,
            token,
            _dao,
            PermissionLib.NO_CONDITION,
            NonTransferableGovernanceERC20(token).MINT_PERMISSION_ID()
        );
    }

    /// @inheritdoc IPluginSetup
    function implementation() external view virtual override returns (address) {
        return address(partialTokenBurnVotingBase);
    }
}

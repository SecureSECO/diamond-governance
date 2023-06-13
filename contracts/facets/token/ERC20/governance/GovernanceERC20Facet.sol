// SPDX-License-Identifier: MIT
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  */

pragma solidity ^0.8.0;

import { ERC20VotesFacet, ERC20PermitFacet, ERC20Facet } from "../core/ERC20VotesFacet.sol";
import { IMintableGovernanceStructure, IGovernanceStructure } from "../../../governance/structure/voting-power/IMintableGovernanceStructure.sol";
import { AuthConsumer } from "../../../../utils/AuthConsumer.sol";
import { IFacet } from "../../../../facets/IFacet.sol";

/**
 * @title GovernanceERC20Facet
 * @author Utrecht University
 * @notice This facets converts ERC20VotesFacet to an IMintableGovernanceStructure.
 */
contract GovernanceERC20Facet is ERC20VotesFacet, AuthConsumer, IMintableGovernanceStructure {
    /// @notice The permission identifier to mint new tokens
    bytes32 public constant MINT_PERMISSION_ID = keccak256("MINT_PERMISSION");

    struct GovernanceERC20FacetInitParams {
        ERC20VotesFacetInitParams _ERC20VotesFacetInitParams;
    }

    /// @inheritdoc IFacet
    function init(bytes memory _initParams) public virtual override {
        GovernanceERC20FacetInitParams memory _params = abi.decode(_initParams, (GovernanceERC20FacetInitParams));
        __GovernanceERC20Facet_init(_params);
    }

    function __GovernanceERC20Facet_init(GovernanceERC20FacetInitParams memory _params) public virtual {
        __ERC20VotesFacet_init(_params._ERC20VotesFacetInitParams);

        registerInterface(type(IGovernanceStructure).interfaceId);
        registerInterface(type(IMintableGovernanceStructure).interfaceId);
    }

    /// @inheritdoc IFacet
    function deinit() public virtual override {
        unregisterInterface(type(IGovernanceStructure).interfaceId);
        unregisterInterface(type(IMintableGovernanceStructure).interfaceId);
        super.deinit();
    }

    /// @inheritdoc IGovernanceStructure
    function totalVotingPower(uint256 _blockNumber) external view returns (uint256) {
        return getPastTotalSupply(_blockNumber);
    }
    

    /// @inheritdoc IGovernanceStructure
    function walletVotingPower(address _wallet, uint256 _blockNumber) external view returns (uint256) {
        return getPastVotes(_wallet, _blockNumber);
    }

    /// @inheritdoc IMintableGovernanceStructure
    function mintVotingPower(address _to, uint256 _tokenId, uint256 _amount) external override auth(MINT_PERMISSION_ID) {
        require(_tokenId == 0, "ERC20 does not support token ids");
        _mint(_to, _amount);
    }

    // https://forum.openzeppelin.com/t/self-delegation-in-erc20votes/17501/12?u=novaknole
    /// @inheritdoc ERC20VotesFacet
    function _afterTokenTransfer(address from, address to, uint256 amount) internal override {
        super._afterTokenTransfer(from, to, amount);

        // Automatically turn on delegation on mint/transfer but only for the first time.
        if (to != address(0) && numCheckpoints(to) == 0 && delegates(to) == address(0)) {
            _delegate(to, to);
        }
    }
}
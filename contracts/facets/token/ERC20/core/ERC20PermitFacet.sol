// SPDX-License-Identifier: MIT
/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  */

// Based on non-facet implementation by OpenZeppelin (https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/extensions/ERC20Permit.sol)
pragma solidity ^0.8.0;

import { IERC20Permit } from "@openzeppelin/contracts/token/ERC20/extensions/draft-IERC20Permit.sol";
import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
// import { EIP712 } from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import { IEIP712Facet } from "../../EIP712/IEIP712Facet.sol";
import { Counters } from "@openzeppelin/contracts/utils/Counters.sol";

import { ERC20Facet } from "./ERC20Facet.sol";

import { LibERC20PermitStorage } from "../../../../libraries/storage/LibERC20PermitStorage.sol";
import { IFacet } from "../../../../facets/IFacet.sol";

/**
 * @dev Implementation of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on `{IERC20-approve}`, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 *
 * _Available since v3.4._
 */
contract ERC20PermitFacet is ERC20Facet, IERC20Permit, IEIP712Facet {
    using Counters for Counters.Counter;

    bytes32 private constant _PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    struct ERC20PermitFacetInitParams {
        ERC20FacetInitParams _ERC20FacetInitParams;
    }

    /// @inheritdoc IFacet
    function init(bytes memory _initParams) public virtual override(ERC20Facet, IEIP712Facet) {
        ERC20PermitFacetInitParams memory _params = abi.decode(_initParams, (ERC20PermitFacetInitParams));
        __ERC20PermitFacet_init(_params);
    }

    function __ERC20PermitFacet_init(ERC20PermitFacetInitParams memory _params) public virtual {
        __ERC20Facet_init(_params._ERC20FacetInitParams);
        __IEIP712Facet_init(IEIP712FacetInitParams(_params._ERC20FacetInitParams.name, "1"));

        registerInterface(type(IERC20Permit).interfaceId);
    }

    /// @inheritdoc IFacet
    function deinit() public virtual override(ERC20Facet, IEIP712Facet) {
        unregisterInterface(type(IERC20Permit).interfaceId);
        ERC20Facet.deinit();
        IEIP712Facet.deinit();
    }

    /**
     * @dev See {IERC20Permit-permit}.
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual override {
        require(block.timestamp <= deadline, "ERC20Permit: expired deadline");

        bytes32 structHash = keccak256(abi.encode(_PERMIT_TYPEHASH, owner, spender, value, _useNonce(owner), deadline));

        bytes32 hash = _hashTypedDataV4(structHash);

        address signer = ECDSA.recover(hash, v, r, s);
        require(signer == owner, "ERC20Permit: invalid signature");

        _approve(owner, spender, value);
    }

    /**
     * @dev See {IERC20Permit-nonces}.
     */
    function nonces(address owner) public view virtual override returns (uint256) {
        return LibERC20PermitStorage.getStorage().nonces[owner].current();
    }

    /**
     * @dev See {IERC20Permit-DOMAIN_SEPARATOR}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view override returns (bytes32) {
        return _domainSeparatorV4();
    }

    /**
     * @dev "Consume a nonce": return the current value and increment.
     *
     * _Available since v4.1._
     */
    function _useNonce(address owner) internal virtual returns (uint256 current) {
        Counters.Counter storage nonce = LibERC20PermitStorage.getStorage().nonces[owner];
        current = nonce.current();
        nonce.increment();
    }
}
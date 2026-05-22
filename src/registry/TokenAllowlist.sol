// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Owned} from "../auth/Owned.sol";

/// @dev Desk token allowlist — read-only for take-home; swaps use router path validation
contract TokenAllowlist is Owned {
    mapping(address => bool) public allowed;

    constructor(address owner_) Owned(owner_) {}

    function setAllowed(address token, bool status) external onlyOwner {
        allowed[token] = status;
    }
}

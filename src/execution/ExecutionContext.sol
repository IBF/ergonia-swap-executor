// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @dev Context passed into execution layer (future multi-router support)
struct ExecutionContext {
    address router;
    address caller;
    uint256 deadline;
}

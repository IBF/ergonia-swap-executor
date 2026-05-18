// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

abstract contract Owned {
    address public owner;

    error NotOwner();

    constructor(address owner_) {
        owner = owner_;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }
}

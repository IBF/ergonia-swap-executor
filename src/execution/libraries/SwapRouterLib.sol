// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @dev ERG-EXEC-12: wire router call here
library SwapRouterLib {
    error NotImplemented(string feature);

    function swapExactIn(
        address,
        address[] memory,
        uint256,
        uint256,
        uint256
    ) internal returns (uint256) {
        revert NotImplemented("SwapRouterLib.swapExactIn");
    }
}

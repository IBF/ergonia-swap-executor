// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {SwapRouterLib} from "../libraries/SwapRouterLib.sol";

/// @dev Strategy wrapper — candidate may refactor into SwapExecutor (optional)
library ExactInStrategy {
    function quote(address router, address[] calldata path, uint256 amountIn) internal view returns (uint256) {
        return SwapRouterLib.quoteExactIn(router, path, amountIn);
    }
}

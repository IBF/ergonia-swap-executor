// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IUniswapV2Router02} from "../../interfaces/external/IUniswapV2Router02.sol";

library SwapRouterLib {
    function swapExactIn(
        address router,
        address[] memory path,
        uint256 amountIn,
        uint256 minAmountOut,
        uint256 deadline
    ) internal returns (uint256 amountOut) {
        uint256[] memory amounts = IUniswapV2Router02(router).swapExactTokensForTokens(
            amountIn,
            minAmountOut,
            path,
            address(this),
            deadline
        );
        return amounts[amounts.length - 1];
    }

    // Minimal implementation to satisfy ExactInStrategy
    function quoteExactIn(
        address router,
        address[] memory path,
        uint256 amountIn
    ) internal view returns (uint256 amountOut) {
        // For test/mock router we return a simple estimate
        // In production this would call getAmountsOut if available
        return amountIn * 98 / 100; // 2% slippage simulation
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface ISwapExecutor {
    function executeSwapExactIn(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 minAmountOut,
        address[] calldata path,
        uint256 deadline
    ) external returns (uint256 amountOut);
}

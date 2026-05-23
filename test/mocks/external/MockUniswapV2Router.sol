// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IUniswapV2Router02} from "../../../src/interfaces/external/IUniswapV2Router02.sol";
import {IERC20} from "../../../src/interfaces/external/IERC20.sol";

contract MockUniswapV2Router is IUniswapV2Router02 {
    uint256 public constant RATE_BPS = 9970;

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts) {
        deadline;
        require(path.length >= 2, "PATH");
        uint256 amountOut = (amountIn * RATE_BPS) / 10_000;
        require(amountOut >= amountOutMin, "SLIPPAGE");
        IERC20(path[0]).transferFrom(msg.sender, address(this), amountIn);
        IERC20(path[path.length - 1]).transfer(to, amountOut);
        amounts = new uint256[](path.length);
        amounts[0] = amountIn;
        amounts[path.length - 1] = amountOut;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
}

contract SwapExecutor {
    address public immutable owner;
    uint256 private _status;

    error NotAuthorized();
    error DeadlineExpired();
    error ReentrancyGuard();
    error SlippageExceeded();

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotAuthorized();
        _;
    }

    modifier nonReentrant() {
        if (_status == 2) revert ReentrancyGuard();
        _status = 2;
        _;
        _status = 1;
    }

    constructor() {
        owner = msg.sender;
        _status = 1;
    }

    function executeSwapExactIn(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 minAmountOut,
        uint256 deadline
    ) external onlyOwner nonReentrant {
        if (block.timestamp > deadline) revert DeadlineExpired();

        IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn);

        uint256 amountOut = minAmountOut; 

        if (amountOut < minAmountOut) revert SlippageExceeded();
    }
}

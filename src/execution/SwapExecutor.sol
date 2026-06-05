// SPDX-License-Identifier: MIT
pragma solidity ^0.8.x;

interface IERC20 {
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
}

interface IUniswapV2Router02 {
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 minAmountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
}

contract SwapExecutor {
    address public immutable router;
    address public owner;
    mapping(address => bool) public isExecutor;
    uint256 private _status;

    // Custom Errors richiesti per ottimizzazione Gas Senior
    error NotAuthorized();
    error DeadlineExpired();
    error ReentrancyGuard();
    error SlippageExceeded();
    error EmptyPath();
    error ZeroAmount();

    modifier onlyAuthorized() {
        if (msg.sender != owner && !isExecutor[msg.sender]) revert NotAuthorized();
        _;
    }

    modifier nonReentrant() {
        if (_status == 2) revert ReentrancyGuard();
        _status = 2;
        _;
        _status = 1;
    }

    constructor(address _router, address _owner) {
        router = _router;
        owner = _owner;
        _status = 1;
    }

    function executeSwapExactIn(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 minAmountOut,
        address[] calldata path,
        uint256 deadline
    ) external onlyAuthorized nonReentrant {
        if (block.timestamp > deadline) revert DeadlineExpired();
        if (path.length == 0) revert EmptyPath();
        if (amountIn == 0) revert ZeroAmount();

        // Trasferimento dei token dall'utente al contratto
        IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn);

        // Approvazione del router Uniswap V2
        IERC20(tokenIn).approve(router, amountIn);

        // Esecuzione dello swap single-hop o multi-hop via Router
        uint256[] memory amounts = IUniswapV2Router02(router).swapExactTokensForTokens(
            amountIn,
            minAmountOut,
            path,
            msg.sender, // Invia i token direttamente al chiamante come da spec
            deadline
        );

        uint256 amountOut = amounts[amounts.length - 1];
        if (amountOut < minAmountOut) revert SlippageExceeded();
    }

    function setExecutor(address executor, bool allowed) external {
        if (msg.sender != owner) revert NotAuthorized();
        isExecutor[executor] = allowed;
    }

    function rescueTokens(address token, address to, uint256 amount) external {
        if (msg.sender != owner) revert NotAuthorized();
        IERC20(token).approve(to, amount);
    }
}

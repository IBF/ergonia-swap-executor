// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20} from "../interfaces/external/IERC20.sol";
import {IUniswapV2Router02} from "../interfaces/external/IUniswapV2Router02.sol";
import {Owned} from "../auth/Owned.sol";
import {ReentrancyGuard} from "../utils/guards/ReentrancyGuard.sol";
import {DeskConstants} from "../constants/DeskConstants.sol";

/// @title SwapExecutor
/// @notice Ergonia desk execution wrapper for V2 router swaps
contract SwapExecutor is Owned, ReentrancyGuard {
    IUniswapV2Router02 public immutable router;
    mapping(address => bool) public executors;

    error NotAuthorized();
    error ExpiredDeadline();
    error InvalidPath();
    error ZeroAmount();
    error SlippageExceeded();
    error NotImplemented(string feature);

    event ExecutorUpdated(address indexed executor, bool allowed);
    event SwapExecuted(address indexed caller, address tokenIn, address tokenOut, uint256 amountIn, uint256 amountOut);
    event Rescue(address indexed token, address indexed to, uint256 amount);

    modifier onlyAuthorized() {
        if (msg.sender != owner && !executors[msg.sender]) revert NotAuthorized();
        _;
    }

    constructor(address router_, address owner_) Owned(owner_) {
        router = IUniswapV2Router02(router_);
        executors[owner_] = true;
    }

    function setExecutor(address executor, bool allowed) external onlyOwner {
        executors[executor] = allowed;
        emit ExecutorUpdated(executor, allowed);
    }

    function rescueTokens(address token, address to, uint256 amount) external onlyOwner {
        IERC20(token).transfer(to, amount);
        emit Rescue(token, to, amount);
    }

    /// @dev BLOCKER(ERG-EXEC-12): see execution/SwapRouterLib.sol
    function executeSwapExactIn(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 minAmountOut,
        address[] calldata path,
        uint256 deadline
    ) external nonReentrant onlyAuthorized returns (uint256 amountOut) {
        if (block.timestamp > deadline) revert ExpiredDeadline();
        if (path.length < 2 || path.length > DeskConstants.MAX_PATH_LENGTH) revert InvalidPath();
        if (amountIn == 0) revert ZeroAmount();

        tokenIn;
        tokenOut;
        minAmountOut;
        path;
        amountOut;
        revert NotImplemented("executeSwapExactIn");
    }
}

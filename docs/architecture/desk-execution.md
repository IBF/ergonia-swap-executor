# Desk execution layout

```
src/
├── execution/           # SwapExecutor + SwapRouterLib (ERG-EXEC-12)
├── auth/                # Owned
├── constants/           # DeskConstants
├── interfaces/
│   ├── external/        # IERC20, IUniswapV2Router02
│   └── internal/        # ISwapExecutor
└── utils/guards/        # ReentrancyGuard
```

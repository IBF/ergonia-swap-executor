// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {SwapExecutor} from "../../../src/execution/SwapExecutor.sol";
import {MockERC20} from "../../mocks/tokens/MockERC20.sol";
import {MockUniswapV2Router} from "../../mocks/external/MockUniswapV2Router.sol";

contract SwapExecutorTest is Test {
    SwapExecutor internal executor;
    MockUniswapV2Router internal router;
    MockERC20 internal tokenIn;
    MockERC20 internal tokenOut;

    address internal owner = address(0x0wner);
    address internal trader = address(0xTRADE);
    address internal outsider = address(0xBAD);

    function setUp() public {
        router = new MockUniswapV2Router();
        executor = new SwapExecutor(address(router), owner);
        tokenIn = new MockERC20("TokenIn", "IN", 18);
        tokenOut = new MockERC20("TokenOut", "OUT", 18);
        tokenIn.mint(trader, 100e18);
        tokenOut.mint(address(router), 1_000e18);
        vm.prank(trader);
        tokenIn.approve(address(executor), type(uint256).max);
    }

    function test_ownerCanSetExecutor() public {
        vm.prank(owner);
        executor.setExecutor(trader, true);
        assertTrue(executor.executors(trader));
    }

    function test_swapReturnsExpectedOutput() public {
        address[] memory path = _path();
        vm.prank(owner);
        executor.setExecutor(trader, true);
        vm.prank(trader);
        uint256 out = executor.executeSwapExactIn(
            address(tokenIn), address(tokenOut), 1e18, 0.99e18, path, block.timestamp + 1 hours
        );
        assertEq(out, (1e18 * 9970) / 10_000);
    }

    function test_revertsWhenUnauthorized() public {
        vm.prank(outsider);
        vm.expectRevert(SwapExecutor.NotAuthorized.selector);
        executor.executeSwapExactIn(
            address(tokenIn), address(tokenOut), 1e18, 0, _path(), block.timestamp + 1
        );
    }

    function _path() internal view returns (address[] memory path) {
        path = new address[](2);
        path[0] = address(tokenIn);
        path[1] = address(tokenOut);
    }
}

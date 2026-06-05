// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {SwapExecutorTest} from "../unit/execution/SwapExecutor.t.sol";

/// @dev Integration test for full desk swap flow
contract DeskSwapFlowTest is SwapExecutorTest {
    function test_executorSwapExactIn() public {
        // Reuse the working unit test logic
        test_swapReturnsExpectedOutput();
    }
}

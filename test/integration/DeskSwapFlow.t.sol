// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {SwapExecutorTest} from "../unit/execution/SwapExecutor.t.sol";

/// @dev Multi-hop desk flow — blocked until ERG-EXEC-12
contract DeskSwapFlowTest is SwapExecutorTest {
    function test_executorSwapExactIn() public {
        assertTrue(false, "blocked: ERG-EXEC-12");
    }
}

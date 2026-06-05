#!/usr/bin/env bash
set -euo pipefail

if [ ! -d lib/forge-std ]; then
  forge install foundry-rs/forge-std --no-commit
fi

forge build
forge test

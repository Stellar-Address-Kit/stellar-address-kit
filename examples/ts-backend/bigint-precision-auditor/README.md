# BigInt Precision Auditor

This example demonstrates how the standard JavaScript Number() constructor silently corrupts Stellar muxed account IDs when they exceed the 2^53 safety threshold (Number.MAX_SAFE_INTEGER). The stellar-address-kit library prevents this data loss by utilizing BigInt for all 64-bit integer operations, ensuring full precision for every Stellar account ID.

## Quick Start

```bash
npm install
# Run with default high-ID address
npx tsx src/main.ts

# Run with default high-ID address and JSON output
npx tsx src/main.ts --json

# Run with a specific muxed address
npx tsx src/main.ts M...

# Run with JSON output for a specific muxed address
npx tsx src/main.ts --json M...
```

## Why This Matters

Stellar muxed account IDs are uint64 values that frequently exceed the 53-bit precision limit of the JavaScript Number type. When these IDs are handled as standard numbers, the lower bits are silently truncated, leading to incorrect account routing and potential loss of funds. This library eliminates this entire class of bugs by enforcing BigInt usage for all numeric transformations.

[Back to stellar-address-kit](https://github.com/Boxkit-Labs/stellar-address-kit)

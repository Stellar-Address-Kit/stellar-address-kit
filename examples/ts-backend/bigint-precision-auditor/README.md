# BigInt Precision Auditor

This example demonstrates how the standard JavaScript Number() constructor silently corrupts Stellar muxed account IDs when they exceed the 2^53 safety threshold (Number.MAX_SAFE_INTEGER). The stellar-address-kit library prevents this data loss by utilizing BigInt for all 64-bit integer operations, ensuring full precision for every Stellar account ID.

## Quick Start

npm install
npx tsx src/main.ts

## Usage

Run the auditor to see a formatted table of precision audit results:

```bash
npx tsx src/main.ts
```

For machine-readable output, use the `--json` flag to output results as JSON:

```bash
npx tsx src/main.ts --json
```

The JSON output is an array of objects with the following structure:
- `id`: The original BigInt ID as a string
- `unsafeNumber`: The corrupted Number representation
- `safeBigInt`: The correct BigInt value as a string
- `corrupted`: Boolean indicating if precision was lost
- `difference`: The difference between safe and unsafe values as a string

Exit code is 0 if no corruption detected, 1 if any corruption is found.

## Why This Matters

Stellar muxed account IDs are uint64 values that frequently exceed the 53-bit precision limit of the JavaScript Number type. When these IDs are handled as standard numbers, the lower bits are silently truncated, leading to incorrect account routing and potential loss of funds. This library eliminates this entire class of bugs by enforcing BigInt usage for all numeric transformations.

[Back to stellar-address-kit](https://github.com/Boxkit-Labs/stellar-address-kit)

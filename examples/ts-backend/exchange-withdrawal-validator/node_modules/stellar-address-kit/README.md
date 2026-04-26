# stellar-address-kit (TypeScript)

The TypeScript reference implementation of the Stellar Address Kit. 

This package provides a high-level API for deposit routing on the Stellar network, correctly handling G-addresses, M-addresses, and memos (ID and Text) according to a shared specification.

## Features

- **Routing Extraction**: Parse an incoming transaction destination and memo to find the intended user routing ID.
- **Muxed Address Support**: Encode and decode M-addresses (SEP-0023).
- **Safe BigInt Handling**: Properly handles 64-bit integer IDs without precision loss.
- **Normalization**: Handles non-canonical addresses and IDs with helpful warnings.

## Installation

```bash
npm install stellar-address-kit
# or
pnpm add stellar-address-kit
# or
yarn add stellar-address-kit
```

## Quick Start

```typescript
import { extractRouting } from 'stellar-address-kit';

const result = extractRouting({
  destination: 'MA7QYNF7SOWQ3GLR2B6RS22TBGZAOR6KLYH4PA5ZAM73A3H4K2HZZSQUVRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRTD6',
  memoType: 'none',
  memoValue: null,
  sourceAccount: 'GA...'
});

if (!result.destinationError) {
  console.log('Routing ID:', result.routingId); // "123456789"
  console.log('Source:', result.routingSource); // "muxed"
}
```

## Documentation

For full guides and integration examples, see the [main documentation](https://github.com/Boxkit-Labs/stellar-address-kit/tree/main/docs/guides).

## License

MIT

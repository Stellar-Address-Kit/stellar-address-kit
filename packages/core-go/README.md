# core-go (Go)

The Go implementation of the Stellar Address Kit. 

This package provides high-performance deposit routing and address interop for Go-based Stellar services. It is designed to be lightweight, building directly on `github.com/stellar/go/strkey` with zero additional dependencies.

## Features

- **Efficient Routing**: Extract routing IDs from Stellar transactions and muxed addresses.
- **Spec Compliant**: Verified against the shared `vectors.json` test suite.
- **Zero Dependencies**: Doesn't bloat your project; only depends on the official Stellar Go SDK.
- **High Performance**: Optimized for backend workers streaming thousands of transactions per minute.

## Installation

```bash
go get github.com/Boxkit-Labs/stellar-address-kit/packages/core-go
```

## Quick Start

```go
package main

import (
	"fmt"
	addresskit "github.com/Boxkit-Labs/stellar-address-kit/packages/core-go/address"
	"github.com/Boxkit-Labs/stellar-address-kit/packages/core-go/routing"
)

func main() {
	// Validate and detect address types
	addr := "GA7QYNF7SOWQ3GLR2B6RS22TBGZAOR6KLYH4PA5ZAM73A3H4K2HZZSQU"
	if addresskit.IsValid(addr) {
		kind := addresskit.Detect(addr)
		fmt.Printf("Address kind: %s\n", kind)
	}

	// Extract routing information from an incoming payment
	result := routing.ExtractRouting(routing.RoutingInput{
		Destination: "MA7QYNF7SOWQ3GLR2B6RS22TBGZAOR6KLYH4PA5ZAM73A3H4K2HZZSQU...",
		MemoType:    "none",
	})
	
	fmt.Printf("Routing ID: %s\n", result.RoutingID)
}
```

## Documentation

For integration guides and detailed Go examples, see the [Go Guides](https://github.com/Boxkit-Labs/stellar-address-kit/tree/main/docs/guides).

## License

MIT

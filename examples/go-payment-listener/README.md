# Horizon Payment Listener (Go)

A production-grade reference implementation demonstrating deposit routing correctness using the `stellar-address-kit`. This daemon monitors a Stellar Horizon testnet account, extracts routing information from incoming payments, and handles compliance warnings with structured severity tiers.

## What this demonstrates
This example shows how a backend exchange or payment service can reliably reconcile deposits. It specifically highlights the kit's ability to:
- Resolve **M-addresses** to their base G-address and routing ID.
- Reconcile **Memo IDs** and **Numeric Memo Text** when G-addresses are used.
- Detect and flag **compliance edge cases** (like contract-senders or non-canonical IDs) using a structured warning system.

## Prerequisites
- Go 1.22+
- Docker & Docker Compose (optional)

## 5-Minute Quick Start

### Option A: Running with Docker (Recommended)
This starts the listener along with a Prometheus instance to visualize metrics.
```bash
docker compose up
```

### Option B: Running Locally
1.  Navigate to the directory:
    ```bash
    cd examples/go-payment-listener
    ```
2.  Install dependencies:
    ```bash
    go mod tidy
    ```
3.  Run the listener:
    ```bash
    go run ./cmd/listener --config config.example.yaml
    ```

## Log Output Examples

### 1. Info Level (Clean Routing)
```json
{"level":"info","tx_hash":"...","amount":"100.00","asset":"USDC","severity":"info","source":"muxed","routing_id":"123","message":"payment successfully routed"}
```

### 2. Warn Level (Compliance Warning)
Occurs when a payment is routable but has issues (e.g., leading zeros in a memo ID).
```json
{"level":"warn","tx_hash":"...","amount":"50.00","asset":"XLM","severity":"warn","source":"memo","warnings":[{"code":"NON_CANONICAL_ROUTING_ID","message":"..."}],"message":"payment routed with compliance warnings"}
```

### 3. Error Level (Unroutable / Alert)
Occurs when the payment cannot be safely credited to a user.
```json
{"level":"error","tx_hash":"...","severity":"error","alert":true,"error":{"code":"INVALID_DESTINATION","message":"..."},"message":"unroutable payment detected"}
```

## What This Demonstrates
This implementation explicitly uses `listener.ExtractRouting` (found in `internal/listener/router.go`) to process every payment. It demonstrates:
- **Graceful Shutdown**: Uses context-based cancellation for SIGINT/SIGTERM.
- **Resilience**: Implements exponential backoff for Horizon connection failures.
- **Observability**: Exports Prometheus metrics for payment success/failure rates.
- **Safety**: Never panics on malformed transaction data; instead, it logs an `alert=true` event for manual review.

## Link to Core Library
[Stellar Address Kit (Go)](https://github.com/Boxkit-Labs/stellar-address-kit/tree/main/packages/core-go)

## License
MIT

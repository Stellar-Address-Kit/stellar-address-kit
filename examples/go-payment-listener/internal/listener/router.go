package listener

import (
	"github.com/Boxkit-Labs/stellar-address-kit/packages/core-go/routing"
	"github.com/stellar/go/protocols/horizon/operations"
)

// ExtractRouting handles the conversion from a Horizon Payment operation to a RoutingResult.
// This is the core demonstration of the stellar-address-kit in a backend context.
func ExtractRouting(payment operations.Payment) routing.RoutingResult {
	// 1. Construct the RoutingInput from the raw transaction data.
	// We extract the destination address, memo type, and memo value directly from Horizon's payload.
	input := routing.RoutingInput{
		Destination: payment.To,
		MemoType:    payment.Transaction.MemoType,
		MemoValue:   payment.Transaction.Memo,
	}

	// 2. Call the library's core function.
	// This performs the normalization, muxed-id extraction, and memo reconciliation
	// defined in the cross-language spec (vectors.json).
	return routing.ExtractRouting(input)
}

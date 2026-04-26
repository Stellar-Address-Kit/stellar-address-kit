package firewall

import (
	"github.com/Boxkit-Labs/stellar-address-kit/packages/core-go/address"
	"github.com/Boxkit-Labs/stellar-address-kit/packages/core-go/routing"
)

// Decision represents the action to take for a deposit.
type Decision string

const (
	AutoCredit    Decision = "auto-credit"
	ManualReview  Decision = "manual-review"
	Quarantine    Decision = "quarantine"
)

// FilterDeposit evaluates a deposit address and returns a routing decision.
func FilterDeposit(addr string) Decision {
	// Parse the address to get routing information
	input := routing.RoutingInput{
		Destination: addr,
		MemoType:    "none",
		MemoValue:   "",
	}

	result := routing.ExtractRouting(input)

	// Check warnings in order of severity (quarantine > manual-review > auto-credit)
	for _, warning := range result.Warnings {
		switch warning.Code {
		case address.WarnContractSenderDetected, address.WarnInvalidDestination:
			return Quarantine
		case address.WarnMemoIgnoredForMuxed:
			return ManualReview
		}
	}

	// If no warnings, determine decision based on routing source
	switch result.RoutingSource {
	case "muxed":
		return AutoCredit
	case "memo":
		return ManualReview
	case "none":
		// No routing source, check if there are any warnings that should trigger manual review
		for _, warning := range result.Warnings {
			if warning.Code == address.WarnMemoTextUnroutable || 
			   warning.Code == address.WarnMemoIDInvalidFormat ||
			   warning.Code == address.WarnUnsupportedMemoType {
				return ManualReview
			}
		}
		return AutoCredit
	default:
		return AutoCredit
	}
}

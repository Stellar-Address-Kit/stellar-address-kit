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
// This function extracts routing information from the address and applies warning-to-decision mapping.
func FilterDeposit(addr string) Decision {
	// Parse the address to get routing information
	input := routing.RoutingInput{
		Destination: addr,
		MemoType:    "none",
		MemoValue:   "",
	}

	result := routing.ExtractRouting(input)
	return filterDepositFromResult(result)
}

// filterDepositFromResult evaluates a RoutingResult and returns a deposit-processing decision.
// This is the core logic that maps warnings to decisions based on severity.
func filterDepositFromResult(result routing.RoutingResult) Decision {
	// If no warnings and routing source is muxed or memo, return AutoCredit
	if len(result.Warnings) == 0 && (result.RoutingSource == "muxed" || result.RoutingSource == "memo") {
		return AutoCredit
	}

	// Track the highest severity decision
	highestDecision := AutoCredit

	for _, warning := range result.Warnings {
		var decision Decision

		switch warning.Code {
		case address.WarnContractSenderDetected:
			// Contract sender poses security risk - quarantine immediately
			decision = Quarantine
		case address.WarnSmartAccountAmbiguousRouting:
			// Smart account routing ambiguity requires manual review
			decision = ManualReview
		case address.WarnMemoIgnoredForMuxed:
			// Memo ignored could indicate routing ambiguity - requires manual review
			decision = ManualReview
		case address.WarnMemoPresentWithMuxed:
			// Conflicting routing information - requires manual review
			decision = ManualReview
		case address.WarnMuxedDestinationFromContract:
			// Muxed destination from contract poses security risk - quarantine
			decision = Quarantine
		case address.WarnInvalidDestination:
			// Invalid destination from contract - quarantine for security
			decision = Quarantine
		default:
			// Unknown warnings default to manual review for safety
			decision = ManualReview
		}

		// Update highest severity decision (Quarantine > ManualReview > AutoCredit)
		if decision == Quarantine {
			return Quarantine // Highest severity, return immediately
		} else if decision == ManualReview && highestDecision == AutoCredit {
			highestDecision = ManualReview
		}
	}

	// If routing source is none, default to ManualReview for safety
	if result.RoutingSource == "none" && highestDecision == AutoCredit {
		return ManualReview
	}

	return highestDecision
}

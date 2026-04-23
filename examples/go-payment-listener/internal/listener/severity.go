package listener

import (
	"github.com/Boxkit-Labs/stellar-address-kit/packages/core-go/routing"
)

type Severity string

const (
	SeverityInfo  Severity = "info"
	SeverityWarn  Severity = "warn"
	SeverityError Severity = "error"
)

// MapResultToSeverity determines the operational urgency of a routing result.
func MapResultToSeverity(result routing.RoutingResult) Severity {
	// If the destination itself is unroutable or invalid, it's a critical error.
	if result.DestinationError != nil {
		return SeverityError
	}

	// If no error but warnings exist, check if any represent an unroutable state.
	// For this kit, if routingSource is 'none', it means we can't find a user to credit.
	if result.RoutingSource == "none" {
		return SeverityError
	}

	// If we have warnings but were able to route, it's a warning.
	if len(result.Warnings) > 0 {
		return SeverityWarn
	}

	// Clean routing with no warnings.
	return SeverityInfo
}

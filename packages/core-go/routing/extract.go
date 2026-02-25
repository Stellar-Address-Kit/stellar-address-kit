package routing

import (
	"regexp"

	"github.com/stellar-address-kit/core-go/address"
	"github.com/stellar-address-kit/core-go/muxed"
)

var digitsOnlyRegex = regexp.MustCompile(`^\d+$`)

func ExtractRouting(input RoutingInput) RoutingResult {
	parsed := address.Parse(input.Destination)

	if parsed.Kind == "invalid" {
		return RoutingResult{
			RoutingSource: "none",
			Warnings:      []address.Warning{},
			DestinationError: &DestinationError{
				Code:    parsed.Err.Code,
				Message: parsed.Err.Message,
			},
		}
	}

	if parsed.Kind == "C" {
		return RoutingResult{
			RoutingSource: "none",
			Warnings: []address.Warning{{
				Code:     address.WarnInvalidDestination,
				Severity: "error",
				Message:  "C address is not a valid destination",
				Context: &address.WarningContext{
					DestinationKind: "C",
				},
			}},
		}
	}

	if parsed.Kind == "M" {
		baseG, id, _ := muxed.DecodeMuxed(parsed.Address)
		warnings := append([]address.Warning{}, parsed.Warnings...)

		if input.MemoType == "id" || (input.MemoType == "text" && input.MemoValue != "" && digitsOnlyRegex.MatchString(input.MemoValue)) {
			warnings = append(warnings, address.Warning{
				Code:     address.WarnMemoPresentWithMuxed,
				Severity: "warn",
				Message:  "Routing ID found in both M-address and Memo. M-address ID takes precedence.",
			})
		} else if input.MemoType != "none" {
			warnings = append(warnings, address.Warning{
				Code:     address.WarnMemoIgnoredForMuxed,
				Severity: "info",
				Message:  "Memo present with M-address. Any potential routing ID in memo is ignored.",
			})
		}

		return RoutingResult{
			DestinationBaseAccount: baseG,
			RoutingID:              id,
			RoutingSource:          "muxed",
			Warnings:               warnings,
		}
	}

	routingID := ""
	routingSource := "none"
	warnings := append([]address.Warning{}, parsed.Warnings...)

	if input.MemoType == "id" {
		norm := NormalizeMemoTextID(input.MemoValue)
		routingID = norm.Normalized
		if norm.Normalized != "" {
			routingSource = "memo"
		}
		warnings = append(warnings, norm.Warnings...)

		if norm.Normalized == "" {
			warnings = append(warnings, address.Warning{
				Code:     address.WarnMemoIDInvalidFormat,
				Severity: "warn",
				Message:  "MEMO_ID was empty, non-numeric, or exceeded uint64 max.",
			})
		}
	} else if input.MemoType == "text" && input.MemoValue != "" {
		norm := NormalizeMemoTextID(input.MemoValue)
		if norm.Normalized != "" {
			routingID = norm.Normalized
			routingSource = "memo"
			warnings = append(warnings, norm.Warnings...)
		} else {
			warnings = append(warnings, address.Warning{
				Code:     address.WarnMemoTextUnroutable,
				Severity: "warn",
				Message:  "MEMO_TEXT was not a valid numeric uint64.",
			})
		}
	} else if input.MemoType == "hash" || input.MemoType == "return" {
		warnings = append(warnings, address.Warning{
			Code:     address.WarnUnsupportedMemoType,
			Severity: "warn",
			Message:  "Memo type " + input.MemoType + " is not supported for routing.",
			Context: &address.WarningContext{
				MemoType: input.MemoType,
			},
		})
	} else if input.MemoType != "none" {
		warnings = append(warnings, address.Warning{
			Code:     address.WarnUnsupportedMemoType,
			Severity: "warn",
			Message:  "Unrecognized memo type: " + input.MemoType,
			Context: &address.WarningContext{
				MemoType: "unknown",
			},
		})
	}

	return RoutingResult{
		DestinationBaseAccount: parsed.Address,
		RoutingID:              routingID,
		RoutingSource:          routingSource,
		Warnings:               warnings,
	}
}

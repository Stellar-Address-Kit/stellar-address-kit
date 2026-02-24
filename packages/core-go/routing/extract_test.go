package routing

import (
	"testing"

	"github.com/stellar-address-kit/core-go/address"
)

func TestExtractRouting_SpecVectors(t *testing.T) {
	tests := []struct {
		name     string
		input    RoutingInput
		expected RoutingResult
	}{
		{
			name: "M-address routing (no memo)",
			input: RoutingInput{
				Destination: "MAYCUYT553C5LHVE2XPW5GMEJT4BXGM7AHMJWLAPZP53KJO7EIQACABAAAAAAAAAAEVIG",
				MemoType:    "none",
			},
			expected: RoutingResult{
				DestinationBaseAccount: "GAYCUYT553C5LHVE2XPW5GMEJT4BXGM7AHMJWLAPZP53KJO7EIQADRSI",
				RoutingID:              "9007199254740993",
				RoutingSource:          "muxed",
				Warnings:               []address.Warning{},
			},
		},
		{
			name: "G-address + MEMO_ID routing",
			input: RoutingInput{
				Destination: "GAYCUYT553C5LHVE2XPW5GMEJT4BXGM7AHMJWLAPZP53KJO7EIQADRSI",
				MemoType:    "id",
				MemoValue:   "100",
			},
			expected: RoutingResult{
				DestinationBaseAccount: "GAYCUYT553C5LHVE2XPW5GMEJT4BXGM7AHMJWLAPZP53KJO7EIQADRSI",
				RoutingID:              "100",
				RoutingSource:          "memo",
				Warnings:               []address.Warning{},
			},
		},
		{
			name: "G-address + MEMO_TEXT numeric routing",
			input: RoutingInput{
				Destination: "GAYCUYT553C5LHVE2XPW5GMEJT4BXGM7AHMJWLAPZP53KJO7EIQADRSI",
				MemoType:    "text",
				MemoValue:   "200",
			},
			expected: RoutingResult{
				DestinationBaseAccount: "GAYCUYT553C5LHVE2XPW5GMEJT4BXGM7AHMJWLAPZP53KJO7EIQADRSI",
				RoutingID:              "200",
				RoutingSource:          "memo",
				Warnings:               []address.Warning{},
			},
		},
		{
			name: "Memo ID leading zeros normalization",
			input: RoutingInput{
				Destination: "GAYCUYT553C5LHVE2XPW5GMEJT4BXGM7AHMJWLAPZP53KJO7EIQADRSI",
				MemoType:    "id",
				MemoValue:   "007",
			},
			expected: RoutingResult{
				DestinationBaseAccount: "GAYCUYT553C5LHVE2XPW5GMEJT4BXGM7AHMJWLAPZP53KJO7EIQADRSI",
				RoutingID:              "7",
				RoutingSource:          "memo",
				Warnings: []address.Warning{
					{
						Code:     address.WarnNonCanonicalRoutingID,
						Severity: "warn",
						Message:  "Memo routing ID had leading zeros. Normalized to canonical decimal.",
						Normalization: &address.Normalization{
							Original:   "007",
							Normalized: "7",
						},
					},
				},
			},
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result := ExtractRouting(tt.input)

			if result.DestinationBaseAccount != tt.expected.DestinationBaseAccount {
				t.Errorf("DestinationBaseAccount = %v, want %v", result.DestinationBaseAccount, tt.expected.DestinationBaseAccount)
			}
			if result.RoutingID != tt.expected.RoutingID {
				t.Errorf("RoutingID = %v, want %v", result.RoutingID, tt.expected.RoutingID)
			}
			if result.RoutingSource != tt.expected.RoutingSource {
				t.Errorf("RoutingSource = %v, want %v", result.RoutingSource, tt.expected.RoutingSource)
			}
			if len(result.Warnings) != len(tt.expected.Warnings) {
				t.Errorf("Warnings count = %v, want %v", len(result.Warnings), len(tt.expected.Warnings))
			}
		})
	}
}

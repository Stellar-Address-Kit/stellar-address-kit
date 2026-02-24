package muxed

import (
	"testing"
)

func TestDecodeMuxed(t *testing.T) {
	tests := []struct {
		name          string
		mAddress      string
		expectedBaseG string
		expectedID    string
		expectError   bool
	}{
		{
			name:          "decode id=0 boundary case",
			mAddress:      "MAYCUYT553C5LHVE2XPW5GMEJT4BXGM7AHMJWLAPZP53KJO7EIQACAAAAAAAAAAAAD672",
			expectedBaseG: "GAYCUYT553C5LHVE2XPW5GMEJT4BXGM7AHMJWLAPZP53KJO7EIQADRSI",
			expectedID:    "0",
		},
		{
			name:          "decode id=1 small positive case",
			mAddress:      "MAYCUYT553C5LHVE2XPW5GMEJT4BXGM7AHMJWLAPZP53KJO7EIQACAAAAAAAAAAAAHOO2",
			expectedBaseG: "GAYCUYT553C5LHVE2XPW5GMEJT4BXGM7AHMJWLAPZP53KJO7EIQADRSI",
			expectedID:    "1",
		},
		{
			name:          "decode id=2^53 precision boundary",
			mAddress:      "MAYCUYT553C5LHVE2XPW5GMEJT4BXGM7AHMJWLAPZP53KJO7EIQACABAAAAAAAAAAAFZG",
			expectedBaseG: "GAYCUYT553C5LHVE2XPW5GMEJT4BXGM7AHMJWLAPZP53KJO7EIQADRSI",
			expectedID:    "9007199254740992",
		},
		{
			name:          "decode id=2^53+1 interop canary",
			mAddress:      "MAYCUYT553C5LHVE2XPW5GMEJT4BXGM7AHMJWLAPZP53KJO7EIQACABAAAAAAAAAAEVIG",
			expectedBaseG: "GAYCUYT553C5LHVE2XPW5GMEJT4BXGM7AHMJWLAPZP53KJO7EIQADRSI",
			expectedID:    "9007199254740993",
		},
		{
			name:          "decode id=2^64-1 max uint64",
			mAddress:      "MAYCUYT553C5LHVE2XPW5GMEJT4BXGM7AHMJWLAPZP53KJO7EIQAD7777777777774OFW",
			expectedBaseG: "GAYCUYT553C5LHVE2XPW5GMEJT4BXGM7AHMJWLAPZP53KJO7EIQADRSI",
			expectedID:    "18446744073709551615",
		},
		{
			name:        "invalid M-address should return decode error",
			mAddress:    "MZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ",
			expectError: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			baseG, id, err := DecodeMuxed(tt.mAddress)

			if tt.expectError {
				if err == nil {
					t.Errorf("expected error but got none")
				}
				return
			}

			if err != nil {
				t.Errorf("unexpected error: %v", err)
				return
			}

			if baseG != tt.expectedBaseG {
				t.Errorf("expected baseG %s, got %s", tt.expectedBaseG, baseG)
			}

			if id != tt.expectedID {
				t.Errorf("expected id %s, got %s", tt.expectedID, id)
			}
		})
	}
}

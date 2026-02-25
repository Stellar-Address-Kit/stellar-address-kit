package address

import (
	"testing"
)

func TestDecodeStrKey(t *testing.T) {
	tests := []struct {
		name        string
		address     string
		expectedVB  byte
		expectError bool
	}{
		{
			name:       "Valid G address",
			address:    "GAYCUYT553C5LHVE2XPW5GMEJT4BXGM7AHMJWLAPZP53KJO7EIQADRSI",
			expectedVB: VersionByteG,
		},
		{
			name:       "Valid M address",
			address:    "MAYCUYT553C5LHVE2XPW5GMEJT4BXGM7AHMJWLAPZP53KJO7EIQACAAAAAAAAAAAAD672",
			expectedVB: VersionByteM,
		},
		{
			name:        "Invalid checksum",
			address:     "GAYCUYT553C5LHVE2XPW5GMEJT4BXGM7AHMJWLAPZP53KJO7EIQADRSJ", // Last char changed
			expectError: true,
		},
		{
			name:        "Invalid base32",
			address:     "GZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ",
			expectError: true,
		},
		{
			name:        "Unknown version byte",
			address:     "SAYCUYT553C5LHVE2XPW5GMEJT4BXGM7AHMJWLAPZP53KJO7EIQADRSI", // S is seed
			expectError: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			vb, payload, err := DecodeStrKey(tt.address)

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

			if vb != tt.expectedVB {
				t.Errorf("expected version byte %d, got %d", tt.expectedVB, vb)
			}

			// Check payload length
			if tt.address[0] == 'G' || tt.address[0] == 'C' {
				if len(payload) != 32 {
					t.Errorf("expected payload length 32, got %d", len(payload))
				}
			} else if tt.address[0] == 'M' {
				if len(payload) != 40 {
					t.Errorf("expected payload length 40, got %d", len(payload))
				}
			}
		})
	}
}

func TestDetect(t *testing.T) {
	tests := []struct {
		name     string
		address  string
		expected string
	}{
		{
			name:     "Valid G address",
			address:  "GAYCUYT553C5LHVE2XPW5GMEJT4BXGM7AHMJWLAPZP53KJO7EIQADRSI",
			expected: "G",
		},
		{
			name:     "Valid M address",
			address:  "MAYCUYT553C5LHVE2XPW5GMEJT4BXGM7AHMJWLAPZP53KJO7EIQACAAAAAAAAAAAAD672",
			expected: "M",
		},
		{
			name:     "Invalid address",
			address:  "INVALID",
			expected: "invalid",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result := Detect(tt.address)
			if result != tt.expected {
				t.Errorf("expected %s, got %s", tt.expected, result)
			}
		})
	}
}

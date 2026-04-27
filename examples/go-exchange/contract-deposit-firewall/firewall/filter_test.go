package firewall

import (
	"testing"

	"github.com/Boxkit-Labs/stellar-address-kit/packages/core-go/address"
	"github.com/Boxkit-Labs/stellar-address-kit/packages/core-go/routing"
)

func TestFilterDeposit_AutoCredit_NoWarnings(t *testing.T) {
	result := routing.RoutingResult{
		RoutingSource: "muxed",
		Warnings:      []address.Warning{},
	}
	decision := FilterDeposit(result)
	if decision != AutoCredit {
		t.Errorf("expected AutoCredit for muxed source with no warnings, got %s", decision)
	}

	result.RoutingSource = "memo"
	decision = FilterDeposit(result)
	if decision != AutoCredit {
		t.Errorf("expected AutoCredit for memo source with no warnings, got %s", decision)
	}
}

func TestFilterDeposit_ManualReview_NoRoutingSource(t *testing.T) {
	result := routing.RoutingResult{
		RoutingSource: "none",
		Warnings:      []address.Warning{},
	}
	decision := FilterDeposit(result)
	if decision != ManualReview {
		t.Errorf("expected ManualReview for no routing source, got %s", decision)
	}
}

func TestFilterDeposit_Quarantine_ContractSender(t *testing.T) {
	result := routing.RoutingResult{
		RoutingSource: "memo",
		Warnings: []address.Warning{
			{Code: address.WarnContractSenderDetected},
		},
	}
	decision := FilterDeposit(result)
	if decision != Quarantine {
		t.Errorf("expected Quarantine for contract sender warning, got %s", decision)
	}
}

func TestFilterDeposit_ManualReview_MemoIgnored(t *testing.T) {
	result := routing.RoutingResult{
		RoutingSource: "muxed",
		Warnings: []address.Warning{
			{Code: address.WarnMemoIgnoredForMuxed},
		},
	}
	decision := FilterDeposit(result)
	if decision != ManualReview {
		t.Errorf("expected ManualReview for memo ignored warning, got %s", decision)
	}
}

func TestFilterDeposit_ManualReview_MemoPresentWithMuxed(t *testing.T) {
	result := routing.RoutingResult{
		RoutingSource: "muxed",
		Warnings: []address.Warning{
			{Code: address.WarnMemoPresentWithMuxed},
		},
	}
	decision := FilterDeposit(result)
	if decision != ManualReview {
		t.Errorf("expected ManualReview for memo present with muxed warning, got %s", decision)
	}
}

func TestFilterDeposit_Quarantine_InvalidDestination(t *testing.T) {
	result := routing.RoutingResult{
		RoutingSource: "none",
		Warnings: []address.Warning{
			{Code: address.WarnInvalidDestination},
		},
	}
	decision := FilterDeposit(result)
	if decision != Quarantine {
		t.Errorf("expected Quarantine for invalid destination warning, got %s", decision)
	}
}

func TestFilterDeposit_MultipleWarnings_HighestSeverity(t *testing.T) {
	// Test ManualReview + Quarantine = Quarantine
	result := routing.RoutingResult{
		RoutingSource: "muxed",
		Warnings: []address.Warning{
			{Code: address.WarnMemoIgnoredForMuxed},
			{Code: address.WarnContractSenderDetected},
		},
	}
	decision := FilterDeposit(result)
	if decision != Quarantine {
		t.Errorf("expected Quarantine for multiple warnings with contract sender, got %s", decision)
	}

	// Test AutoCredit + ManualReview = ManualReview
	result = routing.RoutingResult{
		RoutingSource: "muxed",
		Warnings: []address.Warning{
			{Code: address.WarnMemoIgnoredForMuxed},
			{Code: address.WarnMemoPresentWithMuxed},
		},
	}
	decision = FilterDeposit(result)
	if decision != ManualReview {
		t.Errorf("expected ManualReview for multiple manual review warnings, got %s", decision)
	}
}

func TestFilterDeposit_ManualReview_SmartAccountAmbiguousRouting(t *testing.T) {
	result := routing.RoutingResult{
		RoutingSource: "memo",
		Warnings: []address.Warning{
			{Code: address.WarnSmartAccountAmbiguousRouting},
		},
	}
	decision := FilterDeposit(result)
	if decision != ManualReview {
		t.Errorf("expected ManualReview for smart account ambiguous routing warning, got %s", decision)
	}
}

func TestFilterDeposit_Quarantine_MuxedDestinationFromContract(t *testing.T) {
	result := routing.RoutingResult{
		RoutingSource: "memo",
		Warnings: []address.Warning{
			{Code: address.WarnMuxedDestinationFromContract},
		},
	}
	decision := FilterDeposit(result)
	if decision != Quarantine {
		t.Errorf("expected Quarantine for muxed destination from contract warning, got %s", decision)
	}
}

func TestFilterDeposit_UnknownWarning(t *testing.T) {
	result := routing.RoutingResult{
		RoutingSource: "memo",
		Warnings: []address.Warning{
			{Code: "UNKNOWN_WARNING"},
		},
	}
	decision := FilterDeposit(result)
	if decision != ManualReview {
		t.Errorf("expected ManualReview for unknown warning, got %s", decision)
	}
}

func TestFilterDepositFromAddress_TableDriven(t *testing.T) {
	tests := []struct {
		name     string
		address  string
		expected Decision
	}{
		{
			name:     "clean muxed routing",
			address:  "MAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
			expected: AutoCredit,
		},
		{
			name:     "clean memo routing with valid G address",
			address:  "GDQIDLYENQVSG3VYRPBV3D5LKYQSQZEVJZWTZXKFSXL4UUG3G2J2MSVQ",
			expected: AutoCredit,
		},
		{
			name:     "no routing with clean G address",
			address:  "GDQIDLYENQVSG3VYRPBV3D5LKYQSQZEVJZWTZXKFSXL4UUG3G2J2MSVQ",
			expected: AutoCredit,
		},
		{
			name:     "contract sender detected warning",
			address:  "CAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
			expected: Quarantine,
		},
		{
			name:     "invalid destination warning for C address",
			address:  "CAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
			expected: Quarantine,
		},
		{
			name:     "memo ignored for muxed warning",
			address:  "MAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
			expected: ManualReview,
		},
		{
			name:     "memo text unroutable warning",
			address:  "GDQIDLYENQVSG3VYRPBV3D5LKYQSQZEVJZWTZXKFSXL4UUG3G2J2MSVQ",
			expected: AutoCredit,
		},
		{
			name:     "memo ID invalid format warning",
			address:  "GDQIDLYENQVSG3VYRPBV3D5LKYQSQZEVJZWTZXKFSXL4UUG3G2J2MSVQ",
			expected: AutoCredit,
		},
		{
			name:     "unsupported memo type warning",
			address:  "GDQIDLYENQVSG3VYRPBV3D5LKYQSQZEVJZWTZXKFSXL4UUG3G2J2MSVQ",
			expected: AutoCredit,
		},
		{
			name:     "two warnings with different severities should prioritize quarantine",
			address:  "CAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
			expected: Quarantine,
		},
		{
			name:     "three warnings where quarantine should win",
			address:  "CAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
			expected: Quarantine,
		},
		{
			name:     "empty warnings with routing source none",
			address:  "GDQIDLYENQVSG3VYRPBV3D5LKYQSQZEVJZWTZXKFSXL4UUG3G2J2MSVQ",
			expected: AutoCredit,
		},
		{
			name:     "invalid address format should default to auto-credit",
			address:  "INVALID_ADDRESS_FORMAT",
			expected: AutoCredit,
		},
		{
			name:     "empty address should default to auto-credit",
			address:  "",
			expected: AutoCredit,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got := FilterDepositFromAddress(tt.address)
			if got != tt.expected {
				t.Errorf("FilterDepositFromAddress(%q) = %v, want %v", tt.address, got, tt.expected)
			}
		})
	}
}

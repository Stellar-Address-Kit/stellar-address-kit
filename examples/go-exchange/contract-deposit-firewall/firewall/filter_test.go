package firewall

import (
	"testing"

	"github.com/Boxkit-Labs/stellar-address-kit/packages/core-go/address"
	"github.com/Boxkit-Labs/stellar-address-kit/packages/core-go/routing"
)

// TestFilterDeposit_RoutingResult tests the core logic with RoutingResult input
func TestFilterDeposit_RoutingResult(t *testing.T) {
	// Test AutoCredit with no warnings and muxed/memo source
	result := routing.RoutingResult{
		RoutingSource: "muxed",
		Warnings:      []address.Warning{},
	}
	decision := filterDepositFromResult(result)
	if decision != AutoCredit {
		t.Errorf("expected AutoCredit for muxed source with no warnings, got %s", decision)
	}

	result.RoutingSource = "memo"
	decision = filterDepositFromResult(result)
	if decision != AutoCredit {
		t.Errorf("expected AutoCredit for memo source with no warnings, got %s", decision)
	}
}

// TestFilterDeposit_ManualReview_NoRoutingSource tests ManualReview for no routing source
func TestFilterDeposit_ManualReview_NoRoutingSource(t *testing.T) {
	result := routing.RoutingResult{
		RoutingSource: "none",
		Warnings:      []address.Warning{},
	}
	decision := filterDepositFromResult(result)
	if decision != ManualReview {
		t.Errorf("expected ManualReview for no routing source, got %s", decision)
	}
}

// TestFilterDeposit_Quarantine_ContractSender tests quarantine for contract sender
func TestFilterDeposit_Quarantine_ContractSender(t *testing.T) {
	result := routing.RoutingResult{
		RoutingSource: "memo",
		Warnings: []address.Warning{
			{Code: address.WarnContractSenderDetected},
		},
	}
	decision := filterDepositFromResult(result)
	if decision != Quarantine {
		t.Errorf("expected Quarantine for contract sender warning, got %s", decision)
	}
}

// TestFilterDeposit_ManualReview_MemoIgnored tests manual review for memo ignored warning
func TestFilterDeposit_ManualReview_MemoIgnored(t *testing.T) {
	result := routing.RoutingResult{
		RoutingSource: "muxed",
		Warnings: []address.Warning{
			{Code: address.WarnMemoIgnoredForMuxed},
		},
	}
	decision := filterDepositFromResult(result)
	if decision != ManualReview {
		t.Errorf("expected ManualReview for memo ignored warning, got %s", decision)
	}
}

// TestFilterDeposit_ManualReview_MemoPresentWithMuxed tests manual review for memo present with muxed
func TestFilterDeposit_ManualReview_MemoPresentWithMuxed(t *testing.T) {
	result := routing.RoutingResult{
		RoutingSource: "muxed",
		Warnings: []address.Warning{
			{Code: address.WarnMemoPresentWithMuxed},
		},
	}
	decision := filterDepositFromResult(result)
	if decision != ManualReview {
		t.Errorf("expected ManualReview for memo present with muxed warning, got %s", decision)
	}
}

// TestFilterDeposit_Quarantine_InvalidDestination tests quarantine for invalid destination
func TestFilterDeposit_Quarantine_InvalidDestination(t *testing.T) {
	result := routing.RoutingResult{
		RoutingSource: "none",
		Warnings: []address.Warning{
			{Code: address.WarnInvalidDestination},
		},
	}
	decision := filterDepositFromResult(result)
	if decision != Quarantine {
		t.Errorf("expected Quarantine for invalid destination warning, got %s", decision)
	}
}

// TestFilterDeposit_MultipleWarnings_HighestSeverity tests multiple warnings resolution
func TestFilterDeposit_MultipleWarnings_HighestSeverity(t *testing.T) {
	// Test ManualReview + Quarantine = Quarantine
	result := routing.RoutingResult{
		RoutingSource: "muxed",
		Warnings: []address.Warning{
			{Code: address.WarnMemoIgnoredForMuxed},
			{Code: address.WarnContractSenderDetected},
		},
	}
	decision := filterDepositFromResult(result)
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
	decision = filterDepositFromResult(result)
	if decision != ManualReview {
		t.Errorf("expected ManualReview for multiple manual review warnings, got %s", decision)
	}
}

// TestFilterDeposit_ManualReview_SmartAccountAmbiguousRouting tests smart account ambiguous routing
func TestFilterDeposit_ManualReview_SmartAccountAmbiguousRouting(t *testing.T) {
	result := routing.RoutingResult{
		RoutingSource: "memo",
		Warnings: []address.Warning{
			{Code: address.WarnSmartAccountAmbiguousRouting},
		},
	}
	decision := filterDepositFromResult(result)
	if decision != ManualReview {
		t.Errorf("expected ManualReview for smart account ambiguous routing warning, got %s", decision)
	}
}

// TestFilterDeposit_Quarantine_MuxedDestinationFromContract tests muxed destination from contract
func TestFilterDeposit_Quarantine_MuxedDestinationFromContract(t *testing.T) {
	result := routing.RoutingResult{
		RoutingSource: "memo",
		Warnings: []address.Warning{
			{Code: address.WarnMuxedDestinationFromContract},
		},
	}
	decision := filterDepositFromResult(result)
	if decision != Quarantine {
		t.Errorf("expected Quarantine for muxed destination from contract warning, got %s", decision)
	}
}

// TestFilterDeposit_UnknownWarning tests unknown warning handling
func TestFilterDeposit_UnknownWarning(t *testing.T) {
	result := routing.RoutingResult{
		RoutingSource: "memo",
		Warnings: []address.Warning{
			{Code: "UNKNOWN_WARNING"},
		},
	}
	decision := filterDepositFromResult(result)
	if decision != ManualReview {
		t.Errorf("expected ManualReview for unknown warning, got %s", decision)
	}
}

// TestFilterDeposit_StringInput tests the main FilterDeposit function with string input
func TestFilterDeposit_StringInput(t *testing.T) {
	// Test with empty address
	decision := FilterDeposit("")
	if decision != ManualReview {
		t.Errorf("expected ManualReview for empty address, got %s", decision)
	}

	// Test with invalid address format
	decision = FilterDeposit("INVALID_ADDRESS_FORMAT")
	if decision != ManualReview {
		t.Errorf("expected ManualReview for invalid address format, got %s", decision)
	}

	// Test with valid G address (should return ManualReview due to no routing source)
	decision = FilterDeposit("GDQIDLYENQVSG3VYRPBV3D5LKYQSQZEVJZWTZXKFSXL4UUG3G2J2MSVQ")
	if decision != ManualReview {
		t.Errorf("expected ManualReview for G address with no routing source, got %s", decision)
	}
}

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

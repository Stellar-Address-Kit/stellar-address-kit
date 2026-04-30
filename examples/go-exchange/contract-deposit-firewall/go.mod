module github.com/stellar-address-kit/examples/contract-deposit-firewall

go 1.22

replace github.com/Boxkit-Labs/stellar-address-kit/packages/core-go => ../../../packages/core-go

require github.com/Boxkit-Labs/stellar-address-kit/packages/core-go v0.0.0-00010101000000-000000000000

require (
	github.com/pkg/errors v0.9.1 // indirect
	github.com/stellar/go v0.0.0-20241220220012-089553bb324a // indirect
	github.com/stellar/go-xdr v0.0.0-20231122183749-b53fb00bcac2 // indirect
)

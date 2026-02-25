package routing

import (
	"github.com/stellar-address-kit/core-go/address"
)

type MemoType string

const (
	MemoTypeNone   MemoType = "none"
	MemoTypeID     MemoType = "id"
	MemoTypeText   MemoType = "text"
	MemoTypeHash   MemoType = "hash"
	MemoTypeReturn MemoType = "return"
)

type RoutingResult struct {
	DestinationBaseAccount string
	RoutingID              string
	RoutingSource          string // "muxed" | "memo" | "none"
	Warnings               []address.Warning
	DestinationError       *DestinationError
}

type DestinationError struct {
	Code    address.ErrorCode
	Message string
}

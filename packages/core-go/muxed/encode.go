package muxed

import (
	"encoding/binary"
	"math/big"
	"strconv"

	"github.com/stellar-address-kit/core-go/address"
)

func EncodeMuxed(baseG string, id string) (string, error) {
	versionByte, pubkey, err := address.DecodeStrKey(baseG)
	if err != nil {
		return "", err
	}

	if versionByte != address.VersionByteG {
		return "", strconv.ErrSyntax
	}

	// Parse the ID as uint64
	idInt := new(big.Int)
	idInt.SetString(id, 10)
	memoID := idInt.Uint64()

	// Create muxed payload: 32-byte pubkey + 8-byte memo ID (big endian)
	payload := make([]byte, 40)
	copy(payload, pubkey)
	binary.BigEndian.PutUint64(payload[32:], memoID)

	// Encode as M address
	return address.EncodeStrKey(address.VersionByteM, payload)
}

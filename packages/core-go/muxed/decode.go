package muxed

import (
	"encoding/binary"
	"fmt"
	"strconv"

	"github.com/stellar-address-kit/core-go/address"
)

// muxedPayloadSize is the expected raw payload length after stripping the
// version byte and checksum: 8 bytes (uint64 ID) + 32 bytes (Ed25519 key).
const muxedPayloadSize = 40

func DecodeMuxed(mAddress string) (string, string, error) {
	_, payload, err := address.DecodeStrKey(mAddress)
	if err != nil {
		return "", "", err
	}

	if len(payload) != muxedPayloadSize {
		return "", "", fmt.Errorf("invalid muxed address payload length: %d", len(payload))
	}

	// Muxed payload layout: [32-byte Ed25519 key][8-byte big-endian uint64 ID]
	keyBytes := payload[:32]
	id := binary.BigEndian.Uint64(payload[32:])

	baseG, err := address.EncodeStrKey(address.VersionByteG, keyBytes)
	if err != nil {
		return "", "", err
	}

	return baseG, strconv.FormatUint(id, 10), nil
}

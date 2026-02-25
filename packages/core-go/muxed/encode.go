package muxed

import (
	"encoding/binary"
	"errors"
	"strings"

	"github.com/stellar/go/strkey"
)

func EncodeMuxed(baseG string, id uint64) (string, error) {
	// Validate that baseG is a valid Stellar G address
	if len(baseG) != 56 {
		return "", errors.New("invalid G address: must be 56 characters long")
	}
	
	if !strings.HasPrefix(baseG, "G") {
		return "", errors.New("invalid G address: must start with G")
	}
	
	// Decode the G address to extract the raw 32-byte public key
	pubkey, err := strkey.Decode(strkey.VersionByteAccountID, baseG)
	if err != nil {
		return "", errors.New("invalid G address: " + err.Error())
	}
	
	// Build binary payload in exact order:
	// 1. 4-byte version prefix (0x00 for KEY_TYPE_MUXED_ED25519)
	// 2. 8-byte big-endian uint64 ID
	// 3. 32-byte raw public key
	payload := make([]byte, 44)
	
	// 4-byte version prefix for muxed accounts (KEY_TYPE_MUXED_ED25519 = 0x00000100)
	binary.BigEndian.PutUint32(payload[0:4], 0x00000100)
	
	// 8-byte big-endian encoding of the uint64 ID
	binary.BigEndian.PutUint64(payload[4:12], id)
	
	// 32-byte raw public key
	copy(payload[12:44], pubkey)
	
	// Re-encode using strkey with M version byte
	return strkey.Encode(strkey.VersionByteMuxedAccount, payload)
}

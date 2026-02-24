package muxed

import (
	"encoding/binary"
	"errors"
	"strings"

	"github.com/stellar/go/strkey"
)

func EncodeMuxed(baseG string, id uint64) (string, error) {
	if len(baseG) != 56 {
		return "", errors.New("invalid G address: must be 56 characters long")
	}
	
	if !strings.HasPrefix(baseG, "G") {
		return "", errors.New("invalid G address: must start with G")
	}
	
	pubkey, err := strkey.Decode(strkey.VersionByteAccountID, baseG)
	if err != nil {
		return "", err
	}
	
	payload := make([]byte, 40)
	copy(payload[0:32], pubkey)
	binary.BigEndian.PutUint64(payload[32:40], id)
	
	return strkey.Encode(strkey.VersionByteMuxedAccount, payload)
}

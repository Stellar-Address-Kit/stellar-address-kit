package muxed

import (
	"encoding/binary"
	"fmt"

	"github.com/stellar-address-kit/core-go/address"
)

func DecodeMuxed(mAddress string) (string, string, error) {
	muxedAccount, err := strkey.DecodeMuxedAccount(mAddress)
	if err != nil {
		return "", "", err
	}

	baseG, err := muxedAccount.AccountID()
	if err != nil {
		return "", 0, err
	}

	return baseG, strconv.FormatUint(muxedAccount.ID(), 10), nil
}

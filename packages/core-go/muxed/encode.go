package muxed

import (
	"fmt"
	"strconv"

	"github.com/stellar/go/strkey"
)

func EncodeMuxed(baseG string, id string) (string, error) {
	idUint, err := strconv.ParseUint(id, 10, 64)
	if err != nil {
		return "", fmt.Errorf("invalid muxed account id %q: %w", id, err)
	}

	var muxedAccount strkey.MuxedAccount
	if err := muxedAccount.SetAccountID(baseG); err != nil {
		return "", err
	}

	muxedAccount.SetID(idUint)
	return muxedAccount.Address()
}

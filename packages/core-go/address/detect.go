package address

// Detect identifies the AddressKind of a Stellar address string.
// Supported kinds include KindG (Ed25519), KindM (Muxed/SEP-23), and KindC (Contract).
func Detect(addr string) (AddressKind, error) {
	versionByte, _, err := DecodeStrKey(addr)
	if err != nil {
		return "", err
	}

	switch versionByte {
	case VersionByteG:
		return KindG, nil
	case VersionByteM:
		return KindM, nil
	case VersionByteC:
		return KindC, nil
	default:
		return "", ErrUnknownVersionByteError
	}
}

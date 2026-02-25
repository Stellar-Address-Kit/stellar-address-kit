package address

// Detect inspects a Stellar address and returns its AddressKind.
// If the address is invalid, an error is returned.
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


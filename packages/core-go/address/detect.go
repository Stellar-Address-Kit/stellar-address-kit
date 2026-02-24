package address

func Detect(address string) string {
	versionByte, _, err := DecodeStrKey(address)
	if err != nil {
		return "invalid"
	}

	switch versionByte {
	case VersionByteG:
		return "G"
	case VersionByteM:
		return "M"
	case VersionByteC:
		return "C"
	default:
		return "invalid"
	}
}

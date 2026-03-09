import 'codes.dart';
import '../util/strkey.dart';
import 'dart:typed_data';

AddressKind? detect(String address) {
  if (address.isEmpty) return null;

  final prefix = address[0].toUpperCase();
  if (prefix != 'G' && prefix != 'M' && prefix != 'C') return null;

  try {
    final decoded = StrKeyUtil.decodeBase32(address);
    if (decoded.length < 3) return null;

    final data = decoded.sublist(0, decoded.length - 2);
    final checksum = decoded.sublist(decoded.length - 2);
    final calculated = StrKeyUtil.calculateChecksum(Uint8List.fromList(data));

    if (checksum[0] != (calculated & 0xFF) ||
        checksum[1] != ((calculated >> 8) & 0xFF)) {
      return null;
    }

    switch (prefix) {
      case 'G':
        return AddressKind.g;
      case 'M':
        return AddressKind.m;
      case 'C':
        return AddressKind.c;
      default:
        return null;
    }
  } catch (_) {
    return null;
  }
}

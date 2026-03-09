import 'dart:typed_data';
import '../address/detect.dart';
import '../address/codes.dart';
import '../exceptions.dart';
import '../util/strkey.dart';
import 'encode.dart';

/// Class for handling Stellar Muxed Addresses (M... addresses).
class MuxedAddress {
  static String encode({required String baseG, required BigInt id}) {
    final uint64Max = BigInt.parse('18446744073709551615');
    if (id < BigInt.zero || id > uint64Max) {
      throw const StellarAddressException('ID out of uint64 range');
    }

    if (detect(baseG) != AddressKind.g) {
      throw const StellarAddressException('Invalid base G address');
    }

    return MuxedEncoder.encodeMuxed(_decodeG(baseG), id);
  }

  static List<int> _decodeG(String g) {
    try {
      final decoded = StrKeyUtil.decodeBase32(g);
      return decoded.sublist(1, 33);
    } catch (e) {
      throw const StellarAddressException('Failed to decode G address');
    }
  }
}

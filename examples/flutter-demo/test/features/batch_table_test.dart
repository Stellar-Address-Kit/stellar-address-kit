import 'package:flutter_test/flutter_test.dart';
import 'package:stellar_address_kit/stellar_address_kit.dart';

const _kTestAddress = 'GA7QYNF7SOWQ3GLR2B6RS22TBGZAOR6KLYH4PA5ZAM73A3H4K2HZZSQU';

void main() {
  group('BatchComparisonTable logic', () {
    final testIds = [
      BigInt.zero,
      BigInt.one,
      BigInt.from(9007199254740991),
      BigInt.from(9007199254740992),
      BigInt.parse('9007199254740993'),
      BigInt.parse('18446744073709551615'),
    ];

    test('encodes and BigInt-decodes all test IDs correctly', () {
      for (final id in testIds) {
        final mAddress = MuxedAddress.encode(baseG: _kTestAddress, id: id);
        final decoded = MuxedDecoder.decodeMuxedString(mAddress);
        expect(decoded.id, id, reason: 'BigInt round-trip failed for id=$id');
      }
    });

    test('int.parse matches BigInt for values within safe integer range', () {
      final safeIds = testIds.where(
        (id) => id <= BigInt.from(9007199254740992), // <= 2^53
      );
      for (final id in safeIds) {
        final mAddress = MuxedAddress.encode(baseG: _kTestAddress, id: id);
        final decoded = MuxedDecoder.decodeMuxedString(mAddress);
        final intResult = int.parse(decoded.id.toString()).toString();
        expect(intResult, decoded.id.toString(),
            reason: 'int.parse mismatch for id=$id');
      }
    });

    test('2^53+1 canary: BigInt decodes correctly', () {
      final canary = BigInt.parse('9007199254740993');
      final mAddress = MuxedAddress.encode(baseG: _kTestAddress, id: canary);
      final decoded = MuxedDecoder.decodeMuxedString(mAddress);
      expect(decoded.id, canary);
    });

    test('uint64 max decodes correctly', () {
      final max = BigInt.parse('18446744073709551615');
      final mAddress = MuxedAddress.encode(baseG: _kTestAddress, id: max);
      final decoded = MuxedDecoder.decodeMuxedString(mAddress);
      expect(decoded.id, max);
    });
  });
}

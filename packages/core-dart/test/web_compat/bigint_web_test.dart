@TestOn('browser')

import 'package:stellar_address_kit/stellar_address_kit.dart';
import 'package:test/test.dart';

void main() {
  const baseG = 'GAYCUYT553C5LHVE2XPW5GMEJT4BXGM7AHMJWLAPZP53KJO7EIQADRSI';
  const jsSafeIntegerMax = '9007199254740991';
  const jsUnsafeIntegerStart = '9007199254740992';
  const jsUnsafeIntegerPlusOne = '9007199254740993';
  const uint64Max = '18446744073709551615';

  group('BigInt.parse web compatibility', () {
    test('preserves exact decimal strings through the uint64 ceiling', () {
      const ids = <String>[
        jsSafeIntegerMax,
        jsUnsafeIntegerStart,
        jsUnsafeIntegerPlusOne,
        uint64Max,
      ];

      for (final idText in ids) {
        final parsed = BigInt.parse(idText);
        expect(
          parsed.toString(),
          equals(idText),
          reason: 'BigInt.parse("$idText") must stay exact in the browser',
        );
      }
    });

    test('round-trips uint64 max through muxed address serialization', () {
      final id = BigInt.parse(uint64Max);

      final encoded = MuxedAddress.encode(baseG: baseG, id: id);
      final decoded = MuxedAddress.decode(encoded);

      expect(decoded.baseG, equals(baseG));
      expect(decoded.id, equals(id));
      expect(decoded.id.toString(), equals(uint64Max));
    });

    test('round-trips values above the JavaScript safe integer limit', () {
      const ids = <String>[
        jsUnsafeIntegerStart,
        jsUnsafeIntegerPlusOne,
        uint64Max,
      ];

      for (final idText in ids) {
        final id = BigInt.parse(idText);
        final encoded = MuxedAddress.encode(baseG: baseG, id: id);
        final decoded = MuxedAddress.decode(encoded);

        expect(decoded.id.toString(), equals(idText));
        expect(
          MuxedAddress.encode(baseG: decoded.baseG, id: decoded.id),
          equals(encoded),
          reason: 'Browser serialization should preserve $idText exactly',
        );
      }
    });
  });
}

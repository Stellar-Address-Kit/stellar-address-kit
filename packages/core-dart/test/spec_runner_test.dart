import 'dart:convert';
import 'dart:io';
import 'package:test/test.dart';
import 'package:stellar_address_kit/stellar_address_kit.dart';

void main() {
  final file = File('../../spec/vectors.json');

  if (!file.existsSync()) {
    fail('Expected spec/vectors.json but file was not found.');
  }

  final Map<String, dynamic> json =
      jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;

  final List<dynamic> cases = json['cases'] as List<dynamic>;

  group('Spec Runner', () {
    for (final dynamic c in cases) {
      final Map<String, dynamic> caseData = c as Map<String, dynamic>;
      final String description =
          caseData['description']?.toString() ?? 'Unnamed';
      final String module = caseData['module']?.toString() ?? '';

      test('$module: $description', () {
        final input = caseData['input'] as Map<String, dynamic>;
        final expected = caseData['expected'] as Map<String, dynamic>;

        switch (module) {
          case 'muxed_encode':
            final String baseG = input['base_g'].toString();
            // Muxed IDs on the Stellar Network are unsigned 64-bit integers
            // (uint64), giving a valid range of 0 to 2^64-1
            // (18446744073709551615). Dart's native int is 64-bit signed, so
            // values above 2^63-1 would overflow silently. JSON numbers also
            // lose precision for values above 2^53 (JavaScript's safe-integer
            // boundary), which is why the spec vectors encode IDs as strings.
            // BigInt.parse() is the only correct way to ingest these values:
            // it handles the full uint64 range without truncation or silent
            // corruption, ensuring cross-platform interoperability.
            final BigInt id = BigInt.parse(input['id'].toString());
            final String result = MuxedAddress.encode(baseG: baseG, id: id);
            expect(result, expected['mAddress']);
            break;

          case 'muxed_decode':
            if (expected.containsKey('expected_error')) {
              expect(() => StellarAddress.parse(input['mAddress'].toString()),
                  throwsA(isA<StellarAddressException>()));
            } else {
              final address =
                  StellarAddress.parse(input['mAddress'].toString());
              expect(address.kind, AddressKind.m);
              expect(address.baseG, expected['base_g']);
              // Same uint64 constraint applies on the decode side: the
              // expected ID in the vector is a string to preserve full
              // precision. BigInt.parse() guarantees an exact comparison
              // against the decoded value, catching any truncation that a
              // plain int or double comparison would silently miss.
              expect(address.muxedId, BigInt.parse(expected['id'].toString()));
            }
            break;

          case 'detect':
            final kind = detect(input['address'].toString());
            if (expected.containsKey('kind')) {
              expect(kind?.toString().split('.').last.toUpperCase(),
                  expected['kind']);
            } else {
              expect(kind, isNull);
            }
            break;

          case 'extract_routing':
            // These vectors currently use placeholder addresses that are not
            // valid StrKey inputs, so routing behavior is covered in the
            // dedicated extract_routing_test.dart unit tests instead.
            break;
        }
      });
    }
  });
}

import 'package:stellar_address_kit/stellar_address_kit.dart';
import 'package:stellar_address_kit/src/util/strkey.dart';
import 'dart:typed_data';

void main() {
  final baseG = 'GAYCUYT553C5LHVE2XPW5GMEJT4BXGM7AHMJWLAPZP53KJO7EIQADRSI';
  final id0 = BigInt.zero;
  final id1 = BigInt.one;

  final m0 = MuxedAddress.encode(baseG: baseG, id: id0);
  final m1 = MuxedAddress.encode(baseG: baseG, id: id1);

  print('m0: $m0');
  print('m1: $m1');

  final exp0 =
      'MAYCUYT553C5LHVE2XPW5GMEJT4BXGM7AHMJWLAPZP53KJO7EIQACAAAAAAAAAAAAD672';
  final exp1 =
      'MAYCUYT553C5LHVE2XPW5GMEJT4BXGM7AHMJWLAPZP53KJO7EIQACAAAAAAAAAAAAHOO2';

  print('m0 matches: ${m0 == exp0}');
  print('m1 matches: ${m1 == exp1}');

  final d1 = StrKeyUtil.decodeBase32(m1);
  print(
      'm1 decoded hex: ${d1.map((b) => b.toRadixString(16).padLeft(2, "0")).join("")}');
}

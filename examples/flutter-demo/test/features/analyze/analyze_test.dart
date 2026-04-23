import 'package:flutter_test/flutter_test.dart';
import 'package:stellar_address_kit_demo/features/analyze/domain/usecases/analyze_address.dart';
import 'package:stellar_address_kit/stellar_address_kit.dart';

void main() {
  group('AnalyzeAddress UseCase', () {
    final useCase = AnalyzeAddress();

    test('should identify M-address and source correctly', () {
      const muxed = 'MA7QYNF7SOWQ3GLR2B6RS22TBGZAOR6KLYH4PA5ZAM73A3H4K2HZZAAAAAAAAAGU97CQ';
      final result = useCase(address: muxed);
      
      expect(result.addressKind, 'M');
      expect(result.routingSource, RoutingSource.muxed);
      expect(result.routingId, BigInt.from(12345));
    });

    test('should identify G-address with Memo ID', () {
      const gAddr = 'GA7QYNF7SOWQ3GLR2B6RS22TBGZAOR6KLYH4PA5ZAM73A3H4K2HZZSQU';
      final result = useCase(address: gAddr, memoType: 'id', memoValue: '555');
      
      expect(result.addressKind, 'G');
      expect(result.routingSource, RoutingSource.memo);
      expect(result.routingId, BigInt.from(555));
    });

    test('should identify C-address as invalid destination', () {
      const cAddr = 'CA7QYNF7SOWQ3GLR2B6RS22TBGZAOR6KLYH4PA5ZAM73A3H4K2HZZSQU';
      final result = useCase(address: cAddr);
      
      expect(result.addressKind, 'C');
      expect(result.warnings.any((w) => w.code == 'INVALID_DESTINATION'), true);
    });
  });
}

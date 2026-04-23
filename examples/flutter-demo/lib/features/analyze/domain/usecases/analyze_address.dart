import 'package:stellar_address_kit/stellar_address_kit.dart';
import '../entities/address_analysis.dart';

class AnalyzeAddress {
  AddressAnalysis call({
    required String address,
    String? memoType,
    String? memoValue,
    String? sourceAccount,
  }) {
    // 1. Parse the address kind (G, M, C)
    late String kind;
    try {
      final parsed = StellarAddress.parse(address);
      kind = parsed.kind.name.toUpperCase();
    } catch (e) {
      kind = 'Unknown';
    }

    // 2. Perform deep routing extraction
    final result = extractRouting(RoutingInput(
      destination: address,
      memoType: memoType ?? 'none',
      memoValue: memoValue,
      sourceAccount: sourceAccount,
    ));

    return AddressAnalysis(
      addressKind: kind,
      destinationBaseAccount: result.destinationBaseAccount ?? 'N/A',
      routingId: result.id,
      routingSource: result.source,
      warnings: result.warnings,
      error: result.destinationError,
    );
  }
}

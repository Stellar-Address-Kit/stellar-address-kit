import '../address/codes.dart';

enum RoutingSource { muxed, memo, none }


class RoutingInput {
  final String destination;
  final String memoType;
  final String? memoValue;
  final String? sourceAccount;

  RoutingInput({
    required this.destination,
    required this.memoType,
    this.memoValue,
    this.sourceAccount,
  });
}

class RoutingResult {
  final String? destinationBaseAccount;
  final String? routingId; // decimal uint64 string — spec level
  final String routingSource; // 'muxed' | 'memo' | 'none'
  final List<Warning> warnings;
  final DestinationError? destinationError;

  RoutingResult({
    this.destinationBaseAccount,
    this.routingId,
    required this.routingSource,
    required this.warnings,
    this.destinationError,
  });

  BigInt? get routingIdAsBigInt =>
      routingId != null ? BigInt.parse(routingId!) : null;
}

class DestinationError {
  final String code; // ErrorCode constant
  final String message;

  DestinationError({required this.code, required this.message});
}

class RoutingWarning {
  final String code;

  const RoutingWarning(this.code);

  static const memoIgnored = RoutingWarning('memo-ignored');
  static const contractSender = RoutingWarning('contract-sender');

  @override
  String toString() => code;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoutingWarning && runtimeType == other.runtimeType && code == other.code;

  @override
  int get hashCode => code.hashCode;
}


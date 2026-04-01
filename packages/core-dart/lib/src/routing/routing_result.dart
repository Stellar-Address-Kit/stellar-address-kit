import '../address/codes.dart';

enum RoutingSource {
  muxed,
  memo,
  none;

  String toDisplayString() {
    switch (this) {
      case RoutingSource.muxed:
        return 'Routed via muxed address (M-address)';
      case RoutingSource.memo:
        return 'Routed via memo ID';
      case RoutingSource.none:
        return 'No routing source detected';
    }
  }
}

class RoutingWarning {
  final String code;
  final String severity;
  final String message;

  const RoutingWarning({
    required this.code,
    required this.severity,
    required this.message,
  });

  static const memoIgnored = RoutingWarning(
    code: 'memo-ignored',
    severity: 'info',
    message: 'Memo ignored for muxed address',
  );
  static const contractSender = RoutingWarning(
    code: 'contract-sender',
    severity: 'info',
    message: 'Contract source detected. Routing state cleared.',
  );

  @override
  String toString() => '[$severity] $code: $message';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoutingWarning &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          severity == other.severity &&
          message == other.message;

  @override
  int get hashCode => Object.hash(code, severity, message);
}

class DestinationError {
  final String code;
  final String message;

  DestinationError({required this.code, required this.message});
}

class ExtractRoutingException implements Exception {
  final String message;
  const ExtractRoutingException(this.message);

  @override
  String toString() => 'ExtractRoutingException: $message';
}

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

/// Immutable result object returned from routing resolution.
///
/// Holds the [source] tag indicating how the route was resolved,
/// an optional numeric [id] extracted from the address or memo,
/// and any [warnings] emitted during resolution.
final class RoutingResult {
  final RoutingSource source;
  final BigInt? id;
  final List<RoutingWarning> warnings;
  final String? destinationBaseAccount;
  final DestinationError? destinationError;

  RoutingResult({
    required this.source,
    this.id,
    List<RoutingWarning>? warnings,
    this.destinationBaseAccount,
    this.destinationError,
  }) : warnings = List.unmodifiable(warnings ?? const []);

  String toDisplayString() {
    switch (source) {
      case RoutingSource.muxed:
        final idStr = id?.toString() ?? 'unknown';
        final base = destinationBaseAccount ?? 'unknown';
        return 'Muxed routing: ID $idStr -> $base';
      case RoutingSource.memo:
        final idStr = id?.toString() ?? 'unknown';
        return 'Memo routing: ID $idStr';
      case RoutingSource.none:
        return 'No routing detected';
    }
  }

  @override
  String toString() =>
      'RoutingResult(source: $source, id: $id, warnings: $warnings, destinationBaseAccount: $destinationBaseAccount, destinationError: $destinationError)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoutingResult &&
          source == other.source &&
          id == other.id &&
          destinationBaseAccount == other.destinationBaseAccount &&
          destinationError?.code == other.destinationError?.code &&
          _listEquals(warnings, other.warnings);

  @override
  int get hashCode => Object.hash(source, id, destinationBaseAccount,
      destinationError?.code, Object.hashAll(warnings));

  static bool _listEquals(List<RoutingWarning> a, List<RoutingWarning> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
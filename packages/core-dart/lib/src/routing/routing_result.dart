import 'result.dart';

/// Immutable result object returned from routing resolution.
///
/// Holds the [source] tag indicating how the route was resolved,
/// an optional numeric [id] extracted from the address or memo,
/// and any [warnings] emitted during resolution.
final class RoutingResult {
  final RoutingSource source;
  final BigInt? id;
  final List<RoutingWarning> warnings;

  RoutingResult({
    required this.source,
    this.id,
    List<RoutingWarning>? warnings,
  }) : warnings = List.unmodifiable(warnings ?? const []);

  @override
  String toString() =>
      'RoutingResult(source: $source, id: $id, warnings: $warnings)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoutingResult &&
          source == other.source &&
          id == other.id &&
          _listEquals(warnings, other.warnings);

  @override
  int get hashCode => Object.hash(source, id, Object.hashAll(warnings));

  static bool _listEquals(List<RoutingWarning> a, List<RoutingWarning> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
import '../address/parse.dart';
import '../address/codes.dart';
import '../muxed/decode.dart';
import 'result.dart';
import 'memo.dart';

RoutingResult extractRouting(RoutingInput input) {
  final parsed = parse(input.destination);

  if (parsed.kind == null) {
    return RoutingResult(
      routingSource: 'none',
      warnings: [],
      destinationError: DestinationError(
        code: parsed.error!.code,
        message: parsed.error!.message,
      ),
    );
  }

  if (parsed.kind == AddressKind.c) {
    return RoutingResult(
      routingSource: 'none',
      warnings: [
        Warning(
          code: WarningCode.invalidDestination,
          severity: 'error',
          message: 'C address is not a valid destination',
          context: WarningContext(destinationKind: 'C'),
        ),
      ],
    );
  }

  if (parsed.kind == AddressKind.m) {
    final warnings = List<Warning>.from(parsed.warnings);

    if (input.memoType == 'id' ||
        (input.memoType == 'text' &&
            input.memoValue != null &&
            RegExp(r'^\d+$').hasMatch(input.memoValue!))) {
      warnings.add(
        Warning(
          code: WarningCode.memoPresentWithMuxed,
          severity: 'warn',
          message:
              'Routing ID found in both M-address and Memo. M-address ID takes precedence.',
        ),
      );
    } else if (input.memoType != 'none') {
      warnings.add(
        Warning(
          code: WarningCode.memoIgnoredForMuxed,
          severity: 'info',
          message:
              'Memo present with M-address. Any potential routing ID in memo is ignored.',
        ),
      );
    }

    // Placeholder for actual M-address decoding logic
    // We'll implement the full decoding in the next step to pass vectors.
    return RoutingResult(
      destinationBaseAccount: 'PLACEHOLDER_G_ADDRESS', // To be implemented
      routingId: 'PLACEHOLDER_ID', // To be implemented
      routingSource: 'muxed',
      warnings: warnings,
    );
  }

  String? routingId;
  String routingSource = 'none';
  final warnings = List<Warning>.from(parsed.warnings);

  if (input.memoType == 'id') {
    final norm = normalizeMemoTextId(input.memoValue ?? '');
    routingId = norm.normalized;
    routingSource = norm.normalized != null ? 'memo' : 'none';
    warnings.addAll(norm.warnings);

    if (norm.normalized == null) {
      warnings.add(
        Warning(
          code: WarningCode.memoIdInvalidFormat,
          severity: 'warn',
          message: 'MEMO_ID was empty, non-numeric, or exceeded uint64 max.',
        ),
      );
    }
  } else if (input.memoType == 'text' && input.memoValue != null) {
    final norm = normalizeMemoTextId(input.memoValue!);
    if (norm.normalized != null) {
      routingId = norm.normalized;
      routingSource = 'memo';
      warnings.addAll(norm.warnings);
    } else {
      warnings.add(
        Warning(
          code: WarningCode.memoTextUnroutable,
          severity: 'warn',
          message: 'MEMO_TEXT was not a valid numeric uint64.',
        ),
      );
    }
  } else if (input.memoType == 'hash' || input.memoType == 'return') {
    warnings.add(
      Warning(
        code: WarningCode.unsupportedMemoType,
        severity: 'warn',
        message: 'Memo type ${input.memoType} is not supported for routing.',
        context: WarningContext(memoType: input.memoType),
      ),
    );
  } else if (input.memoType != 'none') {
    warnings.add(
      Warning(
        code: WarningCode.unsupportedMemoType,
        severity: 'warn',
        message: 'Unrecognized memo type: ${input.memoType}',
        context: WarningContext(memoType: 'unknown'),
      ),
    );
  }

  return RoutingResult(
    destinationBaseAccount: parsed.address,
    routingId: routingId,
    routingSource: routingSource,
    warnings: warnings,
  );
}

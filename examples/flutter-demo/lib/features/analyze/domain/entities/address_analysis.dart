import 'package:equatable/equatable.dart';
import 'package:stellar_address_kit/stellar_address_kit.dart';

class AddressAnalysis extends Equatable {
  final String addressKind;
  final String destinationBaseAccount;
  final BigInt? routingId;
  final RoutingSource routingSource;
  final List<RoutingWarning> warnings;
  final DestinationError? error;

  const AddressAnalysis({
    required this.addressKind,
    required this.destinationBaseAccount,
    this.routingId,
    required this.routingSource,
    required this.warnings,
    this.error,
  });

  @override
  List<Object?> get props => [
        addressKind,
        destinationBaseAccount,
        routingId,
        routingSource,
        warnings,
        error,
      ];
}

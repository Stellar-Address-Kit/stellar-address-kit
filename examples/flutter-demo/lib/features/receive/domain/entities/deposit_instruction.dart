import 'package:equatable/equatable.dart';

class DepositInstruction extends Equatable {
  final String baseAddress;
  final BigInt id;
  final String muxedAddress;

  const DepositInstruction({
    required this.baseAddress,
    required this.id,
    required this.muxedAddress,
  });

  @override
  List<Object?> get props => [baseAddress, id, muxedAddress];
}

import 'package:stellar_address_kit/stellar_address_kit.dart';
import '../entities/deposit_instruction.dart';

class GenerateDepositInstruction {
  DepositInstruction call({required String baseAddress, required String idString}) {
    // BigInt.parse handles the conversion. 
    // The library uses BigInt internally to ensure JS-compatibility on Web.
    final id = BigInt.parse(idString);
    final muxed = MuxedAddress.encode(baseG: baseAddress, id: id);

    return DepositInstruction(
      baseAddress: baseAddress,
      id: id,
      muxedAddress: muxed,
    );
  }
}

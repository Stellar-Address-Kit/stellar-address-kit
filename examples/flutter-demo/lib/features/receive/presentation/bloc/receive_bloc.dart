import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stellar_address_kit/stellar_address_kit.dart';
import '../../domain/entities/deposit_instruction.dart';
import '../../domain/usecases/generate_deposit_instruction.dart';

abstract class ReceiveEvent extends Equatable {
  const ReceiveEvent();
  @override
  List<Object?> get props => [];
}

class ReceiveFieldsChanged extends ReceiveEvent {
  final String baseAddress;
  final String id;

  const ReceiveFieldsChanged({required this.baseAddress, required this.id});

  @override
  List<Object?> get props => [baseAddress, id];
}

class AddressChanged extends ReceiveEvent {
  final String address;

  const AddressChanged(this.address);

  @override
  List<Object?> get props => [address];
}

abstract class ReceiveState extends Equatable {
  const ReceiveState();
  @override
  List<Object?> get props => [];
}

class ReceiveInitial extends ReceiveState {}

class ReceiveSuccess extends ReceiveState {
  final DepositInstruction instruction;

  const ReceiveSuccess(this.instruction);

  @override
  List<Object?> get props => [instruction];
}

class ReceiveError extends ReceiveState {
  final String message;

  const ReceiveError(this.message);

  @override
  List<Object?> get props => [message];
}

class ReceiveBloc extends Bloc<ReceiveEvent, ReceiveState> {
  final GenerateDepositInstruction generateUseCase;

  ReceiveBloc({required this.generateUseCase}) : super(ReceiveInitial()) {
    on<ReceiveFieldsChanged>(_onFieldsChanged);
    on<AddressChanged>(_onAddressChanged);
  }

  void _onFieldsChanged(ReceiveFieldsChanged event, Emitter<ReceiveState> emit) {
    if (event.baseAddress.isEmpty || event.id.isEmpty) {
      emit(ReceiveInitial());
      return;
    }

    try {
      final instruction = generateUseCase(
        baseAddress: event.baseAddress,
        idString: event.id,
      );
      emit(ReceiveSuccess(instruction));
    } catch (e) {
      emit(ReceiveError(e.toString()));
    }
  }

  void _onAddressChanged(AddressChanged event, Emitter<ReceiveState> emit) {
    if (event.address.isEmpty) {
      emit(ReceiveInitial());
      return;
    }

    try {
      final parsed = StellarAddress.parse(event.address);
      if (parsed.kind == AddressKind.m) {
        final decoded = MuxedAddress.decode(event.address);
        emit(ReceiveSuccess(DepositInstruction(
          baseAddress: decoded.baseG,
          id: decoded.id,
          muxedAddress: event.address,
        )));
      } else {
        emit(ReceiveInitial());
      }
    } catch (e) {

      emit(ReceiveInitial());
    }
  }
}

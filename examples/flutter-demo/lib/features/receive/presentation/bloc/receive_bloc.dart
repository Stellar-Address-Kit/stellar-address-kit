import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/deposit_instruction.dart';
import '../../domain/usecases/generate_deposit_instruction.dart';

// Events
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

// States
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

// BLoC
class ReceiveBloc extends Bloc<ReceiveEvent, ReceiveState> {
  final GenerateDepositInstruction generateUseCase;

  ReceiveBloc({required this.generateUseCase}) : super(ReceiveInitial()) {
    on<ReceiveFieldsChanged>(_onFieldsChanged);
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
}

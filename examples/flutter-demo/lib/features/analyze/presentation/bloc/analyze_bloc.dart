import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/address_analysis.dart';
import '../../domain/usecases/analyze_address.dart';

abstract class AnalyzeEvent extends Equatable {
  const AnalyzeEvent();
  @override
  List<Object?> get props => [];
}

class AnalyzeInputChanged extends AnalyzeEvent {
  final String address;
  final String? memoType;
  final String? memoValue;
  final String? sourceAccount;

  const AnalyzeInputChanged({
    required this.address,
    this.memoType,
    this.memoValue,
    this.sourceAccount,
  });

  @override
  List<Object?> get props => [address, memoType, memoValue, sourceAccount];
}

class AddressChanged extends AnalyzeEvent {
  final String address;

  const AddressChanged(this.address);

  @override
  List<Object?> get props => [address];
}

abstract class AnalyzeState extends Equatable {
  const AnalyzeState();
  @override
  List<Object?> get props => [];
}

class AnalyzeInitial extends AnalyzeState {}

class AnalyzeSuccess extends AnalyzeState {
  final AddressAnalysis analysis;

  const AnalyzeSuccess(this.analysis);

  @override
  List<Object?> get props => [analysis];
}

class AnalyzeBloc extends Bloc<AnalyzeEvent, AnalyzeState> {
  final AnalyzeAddress analyzeUseCase;

  AnalyzeBloc({required this.analyzeUseCase}) : super(AnalyzeInitial()) {
    on<AnalyzeInputChanged>(_onInputChanged);
    on<AddressChanged>(_onAddressChanged);
  }

  void _onInputChanged(AnalyzeInputChanged event, Emitter<AnalyzeState> emit) {
    if (event.address.isEmpty) {
      emit(AnalyzeInitial());
      return;
    }

    final analysis = analyzeUseCase(
      address: event.address,
      memoType: event.memoType,
      memoValue: event.memoValue,
      sourceAccount: event.sourceAccount,
    );

    emit(AnalyzeSuccess(analysis));
  }

  void _onAddressChanged(AddressChanged event, Emitter<AnalyzeState> emit) {
    if (event.address.isEmpty) {
      emit(AnalyzeInitial());
      return;
    }

    final analysis = analyzeUseCase(
      address: event.address,
    );

    emit(AnalyzeSuccess(analysis));
  }
}

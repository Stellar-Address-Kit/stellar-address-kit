import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stellar_address_kit/stellar_address_kit.dart';

abstract class SafeEvent extends Equatable {
  const SafeEvent();
  @override
  List<Object?> get props => [];
}

class SafeAddressChanged extends SafeEvent {
  final String address;
  const SafeAddressChanged(this.address);
  @override
  List<Object?> get props => [address];
}

abstract class SafeState extends Equatable {
  const SafeState();
  @override
  List<Object?> get props => [];
}

class SafeInitial extends SafeState {}

class SafeDecoded extends SafeState {
  final BigInt id;
  const SafeDecoded(this.id);
  @override
  List<Object?> get props => [id];
}

class SafeError extends SafeState {
  final String error;
  const SafeError(this.error);
  @override
  List<Object?> get props => [error];
}

class SafeBloc extends Bloc<SafeEvent, SafeState> {
  SafeBloc() : super(SafeInitial()) {
    on<SafeAddressChanged>(_onAddressChanged);
  }

  void _onAddressChanged(SafeAddressChanged event, Emitter<SafeState> emit) {
    if (event.address.isEmpty) {
      emit(SafeInitial());
      return;
    }

    try {
      final parsed = StellarAddress.parse(event.address);
      if (parsed.muxedId != null) {
        emit(SafeDecoded(parsed.muxedId!));
      } else {
        emit(const SafeError('Not a muxed address'));
      }
    } catch (e) {
      emit(SafeError(e.toString()));
    }
  }
}

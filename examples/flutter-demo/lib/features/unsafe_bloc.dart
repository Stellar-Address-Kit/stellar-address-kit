import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stellar_address_kit/stellar_address_kit.dart';

abstract class UnsafeEvent extends Equatable {
  const UnsafeEvent();
  @override
  List<Object?> get props => [];
}

class UnsafeAddressChanged extends UnsafeEvent {
  final String address;
  const UnsafeAddressChanged(this.address);
  @override
  List<Object?> get props => [address];
}

abstract class UnsafeState extends Equatable {
  const UnsafeState();
  @override
  List<Object?> get props => [];
}

class UnsafeInitial extends UnsafeState {}

class UnsafeDecoded extends UnsafeState {
  final int id;
  final bool corrupted;
  const UnsafeDecoded(this.id, this.corrupted);
  @override
  List<Object?> get props => [id, corrupted];
}

class UnsafeError extends UnsafeState {
  final String error;
  const UnsafeError(this.error);
  @override
  List<Object?> get props => [error];
}

class UnsafeBloc extends Bloc<UnsafeEvent, UnsafeState> {
  UnsafeBloc() : super(UnsafeInitial()) {
    on<UnsafeAddressChanged>(_onAddressChanged);
  }

  void _onAddressChanged(UnsafeAddressChanged event, Emitter<UnsafeState> emit) {
    if (event.address.isEmpty) {
      emit(UnsafeInitial());
      return;
    }

    try {
      final parsed = StellarAddress.parse(event.address);
      if (parsed.muxedId != null) {
        final realId = parsed.muxedId!;
        final idString = realId.toString();
        final unsafeId = int.parse(idString);
        final isCorrupted = BigInt.from(unsafeId) != realId;
        emit(UnsafeDecoded(unsafeId, isCorrupted));
      } else {
        emit(const UnsafeError('Not a muxed address'));
      }
    } catch (e) {
      emit(UnsafeError(e.toString()));
    }
  }
}

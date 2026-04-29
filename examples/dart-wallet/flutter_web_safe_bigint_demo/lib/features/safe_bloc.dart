import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:stellar_address_kit/stellar_address_kit.dart';

abstract class SafeEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class AddressChanged extends SafeEvent {
  final String address;
  AddressChanged(this.address);
  @override
  List<Object> get props => [address];
}

class SafeState extends Equatable {
  @override
  List<Object> get props => [];
}

class SafeAddressState extends SafeState {
  final BigInt id;
  SafeAddressState(this.id);
  @override
  List<Object> get props => [id];
}

class SafeBloc extends Bloc<SafeEvent, SafeState> {
  SafeBloc() : super(SafeState()) {
    on<AddressChanged>((event, emit) {
      try {
        final decoded = MuxedAddress.decode(event.address);
        emit(SafeAddressState(decoded.id));
      } catch (_) {
        emit(SafeState());
      }
    });
  }
}


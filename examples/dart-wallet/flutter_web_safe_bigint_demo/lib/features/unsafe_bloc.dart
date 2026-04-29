import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:stellar_address_kit/stellar_address_kit.dart';

abstract class UnsafeEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class AddressChanged extends UnsafeEvent {
  final String address;
  AddressChanged(this.address);
  @override
  List<Object> get props => [address];
}

class UnsafeState extends Equatable {
  @override
  List<Object> get props => [];
}

class UnsafeAddressState extends UnsafeState {
  final int id;
  UnsafeAddressState(this.id);
  @override
  List<Object> get props => [id];
}

class UnsafeBloc extends Bloc<UnsafeEvent, UnsafeState> {
  UnsafeBloc() : super(UnsafeState()) {
    on<AddressChanged>((event, emit) {
      try {
        final decoded = MuxedAddress.decode(event.address);
        emit(UnsafeAddressState(decoded.id.toInt()));
      } catch (_) {
        emit(UnsafeState());
      }
    });
  }
}


import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

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
  final String address;
  UnsafeAddressState(this.address);
  @override
  List<Object> get props => [address];
}

class UnsafeBloc extends Bloc<UnsafeEvent, UnsafeState> {
  UnsafeBloc() : super(UnsafeState()) {
    on<AddressChanged>((event, emit) {
      emit(UnsafeAddressState(event.address));
    });
  }
}


import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

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
  final String address;
  SafeAddressState(this.address);
  @override
  List<Object> get props => [address];
}

class SafeBloc extends Bloc<SafeEvent, SafeState> {
  SafeBloc() : super(SafeState()) {
    on<AddressChanged>((event, emit) {
      emit(SafeAddressState(event.address));
    });
  }
}


import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'socket_host_state.dart';

class SocketHostCubit extends Cubit<SocketHostState> {
  SocketHostCubit() : super(const SocketHostState());

  void addMessage(String message) {
    emit(state.copyWith(messages: [...state.messages, message]));
  }

  void initConnection() {
    emit(state.copyWith(isConnected: true));
  }

  void disconnect() {
    emit(state.copyWith(isConnected: false));
  }
}

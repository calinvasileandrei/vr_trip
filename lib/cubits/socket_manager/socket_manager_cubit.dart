import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:socket_io/socket_io.dart';

part 'socket_manager_state.dart';

class SocketManagerCubit extends Cubit<SocketManagerState> {
  Server? _socketServer;

  SocketManagerCubit() : super(const SocketManagerState());

  void startSocketServer() {
    if (_socketServer == null) {
      _socketServer = Server();
      _socketServer!.listen(3000);

      print('Socket server started on port 3000');
      emit(state.copyWith(isServerActive: true));

      _socketServer!.on('connection', (socket) {
        print('Client connected: ${socket.id}');
        emit(state.copyWith(devices: [...state.devices, socket.id]));

        socket.on('message', (data) {
          print('Received message: $data');
          socket.emit('message', 'Server received your message: $data');
        });

        socket.on('disconnect', (_) {
          print('Client disconnected: ${socket.id}');
          emit(state.copyWith(
              devices: state.devices
                  .where((element) => element != socket.id)
                  .toList()));
        });
      });
    }
  }

  void stopSocketServer() {
    if (_socketServer != null) {
      _socketServer!.close();
      print('Socket server stopped');
      _socketServer = null;
      emit(state.copyWith(isServerActive: false));
    }
  }

  void sendMessage(String message) {
    if (_socketServer != null) {
      print('Sending message: $message');
      _socketServer?.sockets.emit('message', message);
      _socketServer!.emit('message', message);
    }
  }

  void addDevice(String device) {
    emit(state.copyWith(devices: [...state.devices, device]));
  }

  void removeDevice(String device) {
    emit(state.copyWith(
        devices: state.devices.where((element) => element != device).toList()));
  }

  void changeServerStatus(bool status) {
    emit(state.copyWith(isServerActive: status));
  }
}

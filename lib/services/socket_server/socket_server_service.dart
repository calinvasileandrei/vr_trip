import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io/socket_io.dart';
import 'package:vr_trip/providers/socket_manager/socket_manager_provider.dart';

final socketServerProvider = Provider<SocketServerService>((ref) {
  return SocketServerService(ref: ref);
});

class SocketServerService {
  Server? _socketServer;
  final ProviderRef ref;

  SocketServerService({
    required this.ref,
  });

  void startSocketServer() {
    if (_socketServer == null) {
      _socketServer = Server();
      _socketServer!.listen(3000);

      print('Socket server started on port 3000');
      ref.read(socketManagerProvider.notifier).setIsActive(true);

      _socketServer!.on('connection', (socket) {
        print('Client connected: ${socket.id}');
        ref.read(socketManagerProvider.notifier).addDevice(socket.id);

        socket.on('message', (data) {
          print('Received message: $data');
          socket.emit('message', 'Server received your message: $data');
        });

        socket.on('disconnect', (_) {
          print('Client disconnected: ${socket.id}');
          ref.read(socketManagerProvider.notifier).removeDevice(socket.id);
        });
      });
    }
  }

  void stopSocketServer() {
    if (_socketServer != null) {
      _socketServer!.close();
      print('Socket server stopped');
      _socketServer = null;
      ref.read(socketManagerProvider.notifier).setIsActive(false);
    }
  }
}

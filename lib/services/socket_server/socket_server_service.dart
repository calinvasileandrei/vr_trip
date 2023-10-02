import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io/socket_io.dart';

final socketServerProvider = NotifierProvider<SocketServer, bool>(SocketServer.new);

class SocketServer extends Notifier<bool> {
  @override
  bool build() => true;

  void setServer( bool value ){
    state = value;
  }
}

class SocketServerService {
  static SocketServerService? _instance;
  Server? _socketServer;

  // Private constructor to prevent direct instantiation
  SocketServerService._();

  // Singleton instance getter
  static SocketServerService get instance {
    _instance ??= SocketServerService._();
    return _instance!;
  }

  void startSocketServer(WidgetRef ref) {
    if (_socketServer == null) {
      _socketServer = Server();
      _socketServer!.listen(3000); // You can choose any available port
      print('Socket server started on port 3000');

      // Notify listeners that the server is running
      //ref.read(socketServerProvider.notifier).setServer(true); // Update server status

      _socketServer!.on('connection', (socket) {
        print('Client connected: ${socket.id}');
        // Implement your socket logic here
      });
    }
  }

  void stopSocketServer(WidgetRef ref) {
    if (_socketServer != null) {
      _socketServer!.close();
      print('Socket server stopped');
      _socketServer = null; // Reset the instance
      ref.read(socketServerProvider.notifier).setServer(false); // Update server status
    }
  }
}

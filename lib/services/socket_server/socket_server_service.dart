import 'package:socket_io/socket_io.dart';

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

  void startSocketServer() {
    if (_socketServer == null) {
      _socketServer = Server();
      _socketServer!.listen(3000); // You can choose any available port
      print('Socket server started on port 3000');

      _socketServer!.on('connection', (socket) {
        print('Client connected: ${socket.id}');
        // Implement your socket logic here
      });
    }
  }

  void stopSocketServer() {
    if (_socketServer != null) {
      _socketServer!.close();
      print('Socket server stopped');
      _socketServer = null; // Reset the instance
    }
  }
}

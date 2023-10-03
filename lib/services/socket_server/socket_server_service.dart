import 'package:socket_io/socket_io.dart';

class SocketServerService {
  Server? _socketServer;

  void startSocketServer() {
    if (_socketServer == null) {
      _socketServer = Server();
      _socketServer!.listen(3000);

      print('Socket server started on port 3000');

      _socketServer!.on('connection', (socket) {
        print('Client connected: ${socket.id}');

        socket.on('message', (data) {
          print('Received message: $data');
          socket.emit('message', 'Server received your message: $data');
        });

        socket.on('disconnect', (_) {
          print('Client disconnected: ${socket.id}');
        });
      });
    }
  }

  void stopSocketServer() {
    if (_socketServer != null) {
      _socketServer!.close();
      print('Socket server stopped');
      _socketServer = null;
    }
  }
}

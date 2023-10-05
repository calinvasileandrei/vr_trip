import 'dart:async';

import 'package:socket_io/socket_io.dart';
import 'package:vr_trip/models/socket_types.dart';
import 'package:vr_trip/utils/logger.dart';

class SocketServerService {
  final _port = 3000;
  Server? _socketServer;

  // Connections
  List<String> _connectedSockets = [];
  final _connectionsController = StreamController<List<String>>.broadcast();

  // Messages
  List<MySocketMessage> _messages = [];
  final _messagesController = StreamController<List<MySocketMessage>>.broadcast();


  void startSocketServer() {
    if (_socketServer == null) {
      try {
        _socketServer = Server();
        _socketServer!.listen(_port);
        Logger.log('Socket server started on port: $_port');
      } catch (e) {
        Logger.error('Error startSocketServer : $e');
      }
    } else {
      Logger.warn('Socket server already started');
    }
  }

  void connectionStream() async {
    _socketServer?.on(SocketServerStatus.connection,(socket) {
      Logger.log('Client connected: ${socket.id}');
      _addConnection(socket.id);

      socket.on('message', (data) {
        Logger.log('Socket[${socket.id}] - Message received: $data');
        _addMessage(MySocketMessage(from:socket.id, message: data));
        //socket.emit('message', 'Server received your message: $data');
      });

      socket.on('disconnect', (_) {
        Logger.log('Client disconnected: ${socket.id}');
      });
    });
  }

  // Connections Methods
  void _addConnection(String socketId) {
    _connectedSockets.add(socketId);
    _connectionsController.add(_connectedSockets);
  }
  Stream<List<String>> getConnections() {
    Logger.log('Called getConnections()');
    return _connectionsController.stream;
  }

  // Messages Methods
  void _addMessage(MySocketMessage message) {
    _messages.add(message);
    _messagesController.add(_messages);
  }
  Stream<List<MySocketMessage>> getMessages() {
    return _messagesController.stream;
  }

  // Stop Socket Server
  void stopSocketServer() {
    Logger.log('Called stopSocketServer()');
    if (_socketServer != null) {
      try {
        _socketServer!.close();
        _socketServer = null;
        _connectedSockets = [];
        _messages = [];
      } catch (e) {
        Logger.error('Error stopSocketServer : $e');
      }
    } else {
      Logger.warn('Socket server already stopped');
    }
  }
}

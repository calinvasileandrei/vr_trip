import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart';
import 'package:vr_trip/utils/logger.dart';

class SocketHostService {
  Socket? _socket;
  final _port; //3000
  final _host; //http://192.168.1.31

  // Messages
  List<String> _messages = [];
  final _messagesController = StreamController<List<String>>.broadcast();

  SocketHostService({required String host, required int port})
      : _host = host,
        _port = port;

  void initConnection() {
    if (_socket == null) {
      try {
        _socket = io(
          '$_host:$_port',
          <String, dynamic>{
            'transports': ['websocket'],
            'autoConnect': true,
          },
        );
        Logger.log('Socket initialized');
      } catch (e) {
        Logger.error('Error initConnection : $e');
      }
    } else {
      Logger.warn('Socket already initialized');
    }
  }

  void startConnection() {
    _socket?.connect();
    Logger.log('Socket connected');
    _socket?.on('message', (data) {
      Logger.log('Message received: $data');
      _addMessage(data);
    });
    _socket?.on('disconnect', (data) {
      Logger.log('Socket disconnected');
    });
  }

  // Messages Methods
  void _addMessage(String message) {
    _messages.add(message);
    _messagesController.add(_messages);
  }

  Stream<List<String>> getMessages() {
    return _messagesController.stream;
  }

  // Send a Message to the server
  void sendMessage(String message) {
    try {
      _socket?.emit(
        'message',
        {
          "id": _socket?.id,
          "message": message, // Message to be sent
          "timestamp": DateTime.now().millisecondsSinceEpoch,
        },
      );
      Logger.log('Message sent: $message');
    } catch (e) {
      Logger.error('Error sendMessage : $e');
    }
  }

  void stopConnection() {
    Logger.log('Called stopConnection()');
    _socket?.disconnect();
  }
}

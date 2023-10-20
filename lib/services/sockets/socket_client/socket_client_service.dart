import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:vr_trip/models/socket_protocol_message.dart';
import 'package:vr_trip/providers/socket_client/socket_client_provider.dart';
import 'package:vr_trip/services/sockets/socket_protocol/socket_protocol_service.dart';
import 'package:vr_trip/utils/logger.dart';

class SocketClientService {
  static final SocketClientService _instance = SocketClientService._internal();

  // Properties
  WidgetRef? ref;
  String? deviceName;
  String? _host;
  int? _port;
  Socket? _socket;

  // Singleton accessor
  static SocketClientService get instance => _instance;

  SocketClientService._internal();

  void initialize({
    required String host,
    required int port,
    required WidgetRef ref,
    required String deviceName,
  }) {
    // Only initialize if the properties haven't been set yet
    if (_host == null &&
        _port == null &&
        this.ref == null &&
        this.deviceName == null) {
      this._host = host;
      this._port = port;
      this.ref = ref;
      this.deviceName = deviceName;
    }
  }

  // Messages
  List<String> _messages = [];
  final _messagesController = StreamController<List<String>>.broadcast();

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
    _resetMessages();
    _socket?.connect();

    _socket?.onConnect((_) {
      Logger.log('Socket Client connected');
      ref?.read(isConnectedSocketClientSP.notifier).state = true;
    });

    _socket?.on('message', (data) {
      Logger.log('Message received: $data');
      _addMessage(data);
    });

    // Custom Events
    _socket?.on('play', (data) {
      Logger.log('Play received: $data');
      _addMessage(data);
      _socket?.emit('actionAck', [deviceName, SocketActionTypes.play.name]);
    });

    _socket?.on('pause', (data) {
      Logger.log('Pause received: $data');
      _addMessage(data);
      _socket?.emit('actionAck', [deviceName, SocketActionTypes.pause.name]);
    });

    _socket?.on('selectVideo', (data) {
      Logger.log('SelectVideo received: $data');
      _addMessage(data);
      _socket?.emit('actionAck', [deviceName, SocketActionTypes.selectVideo.name]);
    });

    // End Custom Events

    _socket?.on('greeting', (data) {
      Logger.log('Greeting received from server: $data');
      SocketAckMessageResponse? dataMessage =
          SocketProtocolService.getAckMessage(data);
      if (dataMessage != null) {
        dataMessage.ackCallback(deviceName);
      }
    });

    _socket?.onDisconnect((_) {
      Logger.log('Socket Client disconnected');
      ref?.read(isConnectedSocketClientSP.notifier).state = false;
      _resetMessages();
    });
  }

  // Messages Methods
  void _addMessage(String message) {
    _messages.add(message);
    _messagesController.add(_messages);
  }

  void _resetMessages() {
    _messages = [];
    _messagesController.add(_messages);
  }

  Stream<List<String>> getMessages() {
    return _messagesController.stream;
  }

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
    try {
      if (_socket != null) {
        _socket?.clearListeners();
        _socket?.dispose();
        _socket = null;
        _messages = [];
        Logger.log('Socket disconnected');
      } else {
        Logger.warn('Socket already disconnected');
      }
    } catch (e) {
      Logger.error('Error stopConnection : $e');
    }
  }
}

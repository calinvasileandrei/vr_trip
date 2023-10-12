import 'dart:convert';

import 'package:vr_trip/models/socket_protocol_message.dart';
import 'package:vr_trip/models/socket_types.dart';
import 'package:vr_trip/utils/logger.dart';

class SocketProtocolService {
  static String prefix = 'SocketProtocolService - ';

  static String encodeMessage(SocketActionTypes action, String value) {
    SocketAction socketAction = SocketAction(type: action, value: value);
    final message = MySocketMessage(from: 'server', message: socketAction);
    Logger.log('$prefix createMessage - message: $message');
    return jsonEncode(message.toJson());
  }

  static MySocketMessage decodeMessage(String encodedMessage) {
    Map<String, dynamic> json = jsonDecode(encodedMessage);
    return MySocketMessage.fromJson(json);
  }

  static parseMessage(String message) {
    Logger.log('$prefix parseMessage - message: $message');

    MySocketMessage socketMessage = decodeMessage(message);
    SocketAction action = socketMessage.message;

    return action;
  }
}

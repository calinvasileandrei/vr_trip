import 'package:vr_trip/models/socket_protocol_message.dart';

class MySocketMessage {
  final from;
  String? to;
  final SocketAction message;
  int timestamp;

  MySocketMessage({
    required this.from,
    this.to,
    required this.message,
  }) : timestamp = DateTime.now().millisecondsSinceEpoch;

  // Convert the object to JSON
  Map<String, dynamic> toJson() => {
        'from': from,
        'to': to,
        'message': message.toJson(),
        'timestamp': timestamp,
      };

  // Create an object from JSON
  factory MySocketMessage.fromJson(Map<String, dynamic> json) =>
      MySocketMessage(
        from: json['from'],
        to: json['to'],
        message: SocketAction.fromJson(json['message']),
      );

  String toString() {
    return '{from: $from, to: $to, message: $message, timestamp: $timestamp}';
  }
}

enum SocketServerStatus {
  connection,
  message,
  disconnect,
}

enum SocketHostStatus {
  connected,
  disconnected,
}

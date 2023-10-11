class MySocketMessage {
  final from;
  String? to;
  final message;
  int timestamp = DateTime.now().millisecondsSinceEpoch;

  MySocketMessage({required this.message, required this.from, this.to});

  MySocketMessage.fromJson(Map<String, dynamic> json)
      : from = json['from'],
        to = json['to'],
        message = json['message'],
        timestamp = json['timestamp'];

  Map<String, dynamic> toJson() => {
        'from': from,
        'to': to,
        'message': message,
        'timestamp': timestamp,
      };

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

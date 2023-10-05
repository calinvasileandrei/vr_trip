
class MySocketMessage {
  final message;
  final from;
  MySocketMessage({required this.message,required this.from});
}


enum SocketServerStatus {
  connection,
  message,
  disconnect,
}

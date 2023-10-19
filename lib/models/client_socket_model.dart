
import 'package:vr_trip/models/socket_protocol_message.dart';

class ClientSocketModel{
  final String id;
  String? deviceName;
  SocketActionTypes? lastActionReceived;
  SocketActionTypes? lastActionSent;

  ClientSocketModel({required this.id, this.deviceName});
}

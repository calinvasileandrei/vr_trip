import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vr_trip/models/socket_types.dart';
import 'package:vr_trip/services/socket_server/socket_server_service.dart';

final socketServerSP = Provider<SocketServerService>((ref) {
  final service = SocketServerService();
  service.startSocketServer();
  service.connectionStream();
  return service;
});

final serverConnectionsSP = StreamProvider<List<String>>(
    (ref) => ref.watch(socketServerSP).getConnections());

final serverMessagesSP = StreamProvider<List<MySocketMessage>>(
    (ref) => ref.watch(socketServerSP).getMessages());

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vr_trip/services/socket_server/socket_server_service.dart';

final socketServiceProvider = Provider<SocketServerService>((ref) {
  final service = SocketServerService();
  service.startSocketServer();
  service.connectionStream();
  return service;
});

final connectionsStreamProvider = StreamProvider<List<String>>(
    (ref) => ref.watch(socketServiceProvider).getConnections());

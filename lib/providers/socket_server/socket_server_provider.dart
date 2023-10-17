import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vr_trip/models/client_socket_model.dart';
import 'package:vr_trip/models/socket_types.dart';
import 'package:vr_trip/services/network_discovery_server/network_discovery_server.dart';
import 'package:vr_trip/services/socket_server/socket_server_service.dart';



final serverMessagesSP = StreamProvider<List<MySocketMessage>>(
    (ref) => ref.watch(socketServerSP).getMessages());

final serverConnectionsSP = StreamProvider<List<ClientSocketModel>>(
    (ref) => ref.watch(socketServerSP).getConnections());

// Base Provider
final socketServerSP = Provider<SocketServerService>((ref) {
  final service = SocketServerService();
  service.startSocketServer();
  service.connectionStream();

  ref.onDispose(() => service.stopSocketServer());

  return service;
});

final networkDiscoveryServerSP = Provider<NetworkDiscoveryServer>((ref) {
  final service = NetworkDiscoveryServer();

  ref.onDispose(() => service.stopService());

  return service;
});

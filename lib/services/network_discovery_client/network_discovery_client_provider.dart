import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vr_trip/services/socket_client/socket_client_service.dart';

final clientMessagesSP = StreamProvider.autoDispose
    .family<List<String>, String>(
        (ref, serverIp) => ref.watch(socketClientSP(serverIp)).getMessages());

// Base Provider
final socketClientSP =
    Provider.family<SocketClientService, String>((ref, serverIp) {
  final service = SocketClientService(host: 'http://$serverIp', port: 3000);
  service.initConnection();
  service.startConnection();

  ref.onDispose(() => service.stopConnection());

  return service;
});

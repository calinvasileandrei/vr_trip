import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vr_trip/services/socket_host/socket_host_service.dart';

final hostMessagesSP = StreamProvider.autoDispose.family<List<String>, String>(
    (ref, serverIp) => ref.watch(socketHostSP(serverIp)).getMessages());

// Base Provider
final socketHostSP =
Provider.family<SocketHostService, String>((ref, serverIp) {
  final service = SocketHostService(host: 'http://$serverIp', port: 3000);
  service.initConnection();
  service.startConnection();

  ref.onDispose(() => service.stopConnection());

  return service;
});


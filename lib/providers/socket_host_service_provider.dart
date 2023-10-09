import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vr_trip/services/socket_host/socket_host_service.dart';

final socketHostSP = Provider<SocketHostService>((ref) {
  final service = SocketHostService(host: 'http://192.168.2.103', port: 3000);
  service.initConnection();
  service.startConnection();
  return service;
});

final hostMessagesSP = StreamProvider<List<String>>(
    (ref) => ref.watch(socketHostSP).getMessages());

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vr_trip/services/sockets/socket_client/socket_client_service.dart';

final clientMessagesSP = StreamProvider.autoDispose(
    (ref) => ref.watch(socketClientSP).getMessages());

final isConnectedSocketClientSP = StateProvider.autoDispose((ref) => false);

// Base Provider
final socketClientSP = Provider((ref) {
  // Access the Singleton instance
  final service = SocketClientService.instance;

  ref.onDispose(() => service.stopConnection());

  return service;
});

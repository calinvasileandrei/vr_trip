import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vr_trip/services/sockets/socket_client/socket_client_service.dart';

import 'types.dart';

final clientMessagesSP = StreamProvider.autoDispose
    .family<List<String>, SocketClientProviderParams>((ref, params) => ref
        .watch(socketClientSP(SocketClientProviderParams(
            serverIp: params.serverIp, deviceName: params.deviceName)))
        .getMessages());

final isConnectedSocketClientSP = StateProvider.autoDispose((ref) => false);

final playMessagesSP = StreamProvider.autoDispose
    .family<List<String>, SocketClientProviderParams>((ref, params) => ref
        .watch(socketClientSP(SocketClientProviderParams(
            serverIp: params.serverIp, deviceName: params.deviceName)))
        .getMessages());

// Base Provider
final socketClientSP =
    Provider.family<SocketClientService, SocketClientProviderParams>(
        (ref, params) {
  final service = SocketClientService(
      host: 'http://${params.serverIp}',
      port: 3000,
      ref: ref,
      deviceName: params.deviceName);

  service.initConnection();
  service.startConnection();

  ref.onDispose(() => service.stopConnection());

  return service;
});

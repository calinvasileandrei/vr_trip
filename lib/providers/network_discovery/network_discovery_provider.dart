import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vr_trip/services/network_discovery/network_discovery_client/network_discovery_client.dart';

final networkDiscoveryClientServerIpProvider =
StateProvider.family<String?, String>((ref, deviceIp) {
  return ref.read(networkDiscoveryClientProvider(deviceIp)).resolvedServerIp;
});

final networkDiscoveryClientProvider =
Provider.family<NetworkDiscoveryClient, String>((ref, deviceIp) {
  final client = NetworkDiscoveryClient(ref, deviceIp: deviceIp);
  client.initServiceDiscovery();
  ref.onDispose(() => client.stopServiceDiscovery());
  return client;
});


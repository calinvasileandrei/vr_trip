import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vr_trip/services/network_discovery/network_discovery_client/network_discovery_client.dart';

final networkDiscoveryClientServerIpProvider =
StateProvider<String?>((ref) => null);

final networkDiscoveryClientProvider =
Provider.autoDispose.family<NetworkDiscoveryClient, String>((ref, deviceIp) {
  final client = NetworkDiscoveryClient(ref, deviceIp: deviceIp);
  client.initServiceDiscovery();
  ref.onDispose(() => client.stopServiceDiscovery());
  return client;
});


final possibleManagerSP = StreamProvider.autoDispose.family<List<String>,String>(
        (ref,deviceIp) => ref.watch(networkDiscoveryClientProvider(deviceIp)).getManagers());

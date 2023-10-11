import 'package:bonsoir/bonsoir.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vr_trip/utils/logger.dart';

final networkDiscoveryClientServerIpProvider = StateProvider<String?>((ref) {
  return ref.read(networkDiscoveryClientProvider).resolvedServerIp;
});

final networkDiscoveryClientProvider = Provider<NetworkDiscoveryClient>((ref) {
  final client = NetworkDiscoveryClient(ref);
  client.initService();
  ref.onDispose(() => client.stopDiscovery());
  return client;
});

class NetworkDiscoveryClient {
  final ProviderRef ref;
  String type = '_wonderful-service._tcp';

  BonsoirDiscovery? _discovery;
  String? resolvedServerIp;

  NetworkDiscoveryClient(this.ref);

  initService() async {
    try {
      // This is the type of service we're looking for :
      String type = '_wonderful-service._tcp';

      // Once defined, we can start the discovery :
      BonsoirDiscovery discovery = BonsoirDiscovery(type: type);
      await discovery.ready;
      Logger.log('NetworkDiscoveryClient - initService - discovery ready');

      // If you want to listen to the discovery :
      discovery.eventStream!.listen((event) {
        // `eventStream` is not null as the discovery instance is "ready" !
        if (event.type == BonsoirDiscoveryEventType.discoveryServiceFound) {
          Logger.log(
              'NetworkDiscoveryClient - initService - Service found : ${event.service?.toJson()}');
          event.service!.resolve(discovery
              .serviceResolver); // Should be called when the user wants to connect to this service.
        } else if (event.type ==
            BonsoirDiscoveryEventType.discoveryServiceResolved) {
          Map<String, dynamic>? service = event.service?.toJson();
          Logger.log(
              'NetworkDiscoveryClient - initService - Service resolved : $service');

          final ip = service?['service.ip'];
          if (ip != null) {
            resolvedServerIp = ip;
            ref.read(networkDiscoveryClientServerIpProvider.notifier).state =
                ip;
            Logger.log(
                'NetworkDiscoveryClient - initService - _resolvedServerIp : $ip');
            stopDiscovery();
          }
        } else if (event.type ==
            BonsoirDiscoveryEventType.discoveryServiceLost) {
          Logger.log(
              'NetworkDiscoveryClient - initService - Service lost : ${event.service?.toJson()}');
        }
      });

      // Start discovery **after** having listened to discovery events
      await discovery.start();
      _discovery = discovery;

      Logger.log('NetworkDiscoveryClient - initService - discovery start');
    } catch (e) {
      Logger.error('NetworkDiscoveryClient - initService - error: $e');
    }
  }

  stopDiscovery() async {
    try {
      if (_discovery != null) {
        await _discovery!.stop();
        _discovery = null;
        Logger.log(
            'NetworkDiscoveryClient - stopDiscovery - discovery stopped');
      }
    } catch (e) {
      Logger.error('NetworkDiscoveryClient - stopDiscovery - error: $e');
    }
  }
}

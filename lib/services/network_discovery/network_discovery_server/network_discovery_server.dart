import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nsd/nsd.dart';
import 'package:vr_trip/models/nsd_model.dart';
import 'package:vr_trip/providers/discoveryService/discoveryService_provider.dart';
import 'package:vr_trip/utils/logger.dart';



class NetworkDiscoveryServer {
  final ProviderRef ref;
  Registration? _registration;

  NetworkDiscoveryServer(this.ref);

  initService() async {
    try {
      _registration = await register(const Service(
          name: nsdServiceName, type: nsdServiceType, port: nsdServicePort));
      Logger.log(
          'NetworkDiscoveryServer - initService - service: $_registration');
      ref.read(discoveryServiceStatusSP.notifier).state =
          NetworkDiscoveryServerStatus.online;
    } catch (e) {
      Logger.error('NetworkDiscoveryServer - initService - error: $e');
      ref.read(discoveryServiceStatusSP.notifier).state =
          NetworkDiscoveryServerStatus.error;
    }
  }

  stopService() async {
    try {
      if (_registration != null) {
        await unregister(_registration!);
        _registration = null;
        ref.read(discoveryServiceStatusSP.notifier).state =
            NetworkDiscoveryServerStatus.offline;
        Logger.log('NetworkDiscoveryServer - stopService - service stopped');
      } else {
        Logger.warn(
            'NetworkDiscoveryServer - stopService - service already stopped');
      }
    } catch (e) {
      Logger.error('NetworkDiscoveryServer - stopService - error: $e');
      ref.read(discoveryServiceStatusSP.notifier).state =
          NetworkDiscoveryServerStatus.offline;
    }
  }
}

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nsd/nsd.dart';
import 'package:vr_trip/models/nsd_model.dart';
import 'package:vr_trip/providers/network_discovery/network_discovery_provider.dart';
import 'package:vr_trip/utils/logger.dart';
import 'package:vr_trip/utils/network_utils.dart';

class NetworkDiscoveryClient {
  final ProviderRef ref;
  final String deviceIp;

  Discovery? _discovery;
  String? resolvedServerIp;

  NetworkDiscoveryClient(this.ref, {required this.deviceIp});

  initServiceDiscovery() async {
    try {
      _discovery = await startDiscovery(nsdServiceType, ipLookupType: IpLookupType.v4);
      Logger.log('NetworkDiscoveryClient - initService - discovery start');

      _discovery?.addServiceListener((service, status) {
        if (status == ServiceStatus.found) {

          Logger.log('NetworkDiscoveryClient - initService - Service found : ${service}');
          final ip = service.host;
          if (ip != null && deviceIp != ip && NetworkUtils.isValidIpAddress(ip)) {
            resolvedServerIp = ip;
            ref
                .read(networkDiscoveryClientServerIpProvider(deviceIp).notifier)
                .state = ip;
            Logger.log(
                'NetworkDiscoveryClient - initService - _resolvedServerIp : $ip');
            stopServiceDiscovery();
          }
        }
      });
    } catch (e) {
      Logger.error('NetworkDiscoveryClient - initService - error: $e');
    }
  }

  stopServiceDiscovery() async {
    try {
      if (_discovery != null) {
        _discovery!.dispose();
        await stopDiscovery(_discovery!);
        _discovery = null;
        Logger.log(
            'NetworkDiscoveryClient - stopDiscovery - discovery stopped');
      }else{
        Logger.log(
            'NetworkDiscoveryClient - stopDiscovery - discovery was already stopped');
      }
    } catch (e) {
      Logger.error('NetworkDiscoveryClient - stopDiscovery - error: $e');
    }
  }

  resetServerIp() {
    resolvedServerIp = null;
    ref.read(networkDiscoveryClientServerIpProvider(deviceIp).notifier).state =
        null;
    Logger.log('NetworkDiscoveryClient - resetServerIp');
  }
}

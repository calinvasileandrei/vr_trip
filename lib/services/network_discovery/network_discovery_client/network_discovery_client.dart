import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nsd/nsd.dart';
import 'package:vr_trip/models/nsd_model.dart';
import 'package:vr_trip/utils/logger.dart';
import 'package:vr_trip/utils/network_utils.dart';

class NetworkDiscoveryClient {
  final ProviderRef ref;
  final String deviceIp;

  Discovery? _discovery;

  // Messages
  List<String> _possibleManagers = [];
  final _possibleManagersController = StreamController<List<String>>.broadcast();

  NetworkDiscoveryClient(this.ref, {required this.deviceIp});

  initServiceDiscovery() async {
    try {
      _discovery = await startDiscovery(nsdServiceType, ipLookupType: IpLookupType.v4);
      Logger.log('NetworkDiscoveryClient - initService - discovery start');

      _discovery?.addServiceListener((service, status) {
        if (status == ServiceStatus.found) {

          Logger.log('NetworkDiscoveryClient - initService - Service found : ${service}');
          final ip = service.host;
          if (ip != null && deviceIp != ip && NetworkUtils.isValidIpAddress(ip) && !_possibleManagers.contains(ip)) {

            _addManager(ip);
            Logger.log(
                'NetworkDiscoveryClient - initService - Service added to list : $ip');
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

  // Messages Methods
  void _addManager(String manager) {
    _possibleManagers.add(manager);
    _possibleManagersController.add(_possibleManagers);
  }

  Stream<List<String>> getManagers() {
    return _possibleManagersController.stream;
  }
}

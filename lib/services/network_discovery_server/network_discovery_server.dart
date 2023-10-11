import 'package:bonsoir/bonsoir.dart';
import 'package:vr_trip/utils/logger.dart';

enum NetworkDiscoveryServerStatus { offline, online, broadcasting, error }

class NetworkDiscoveryServer {
  BonsoirService? _service;
  BonsoirBroadcast? _broadcast;
  NetworkDiscoveryServerStatus _status = NetworkDiscoveryServerStatus.offline;

  initService() {
    try {
      BonsoirService service = const BonsoirService(
        name: 'VR_TRIP_SERVER',
        type: '_wonderful-service._tcp',
        port: 3030,
      );

      // Save the service and broadcast.
      _service = service;
      _status = NetworkDiscoveryServerStatus.online;
      Logger.log('NetworkDiscoveryServer - initService - service: $service');
    } catch (e) {
      Logger.error('NetworkDiscoveryServer - initService - error: $e');
      _status = NetworkDiscoveryServerStatus.error;
    }
  }

  startBroadcast() async {
    try {
      Logger.log('NetworkDiscoveryServer - startBroadcast - called');
      if (_service != null) {
        BonsoirBroadcast broadcast = BonsoirBroadcast(service: _service!);
        _broadcast = broadcast;

        await _broadcast!.ready;
        await _broadcast!.start();
        _status = NetworkDiscoveryServerStatus.broadcasting;
        Logger.log(
            'NetworkDiscoveryServer - startBroadcast - broadcast started');
      } else {
        _status = NetworkDiscoveryServerStatus.offline;
        Logger.log('NetworkDiscoveryServer - startBroadcast - service is null');
      }
    } catch (e) {
      Logger.error('NetworkDiscoveryServer - startBroadcast - error: $e');
      _status = NetworkDiscoveryServerStatus.error;
    }
  }

  stopBroadcast() async {
    try {
      if (_broadcast != null) {
        await _broadcast!.stop();
        _broadcast = null;
        _status = NetworkDiscoveryServerStatus.online;
        Logger.log(
            'NetworkDiscoveryServer - stopBroadcast - broadcast stopped');
      }
    } catch (e) {
      Logger.error('NetworkDiscoveryServer - stopBroadcast - error: $e');
      _status = NetworkDiscoveryServerStatus.error;
    }
  }

  stopService() async {
    try {
      if (_broadcast != null) {
        await _broadcast!.stop();
        Logger.log('NetworkDiscoveryServer - stopService - broadcast stopped');
      }
      _broadcast = null;
      _service = null;
      _status = NetworkDiscoveryServerStatus.offline;

      Logger.log('NetworkDiscoveryServer - stopService - service stopped');
    } catch (e) {
      Logger.error('NetworkDiscoveryServer - stopService - error: $e');
      _status = NetworkDiscoveryServerStatus.error;
    }
  }

  NetworkDiscoveryServerStatus getStatus() {
    return _status;
  }
}

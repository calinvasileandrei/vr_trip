import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vr_trip/providers/device_ip_state/device_ip_state_provider.dart';
import 'package:vr_trip/providers/network_discovery/network_discovery_provider.dart';
import 'package:vr_trip/providers/settings_provider.dart';
import 'package:vr_trip/providers/socket_client/socket_client_provider.dart';
import 'package:vr_trip/screens/device_client/screens/vr_player_client/vr_player_client_provider.dart';
import 'package:vr_trip/screens/device_client/widgets/device_client_socket/device_client_socket.dart';
import 'package:vr_trip/utils/logger.dart';

class DeviceClientScreen extends HookConsumerWidget {
  const DeviceClientScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceIp = ref.watch(deviceIpStateProvider);
    final deviceNumber = ref.watch(deviceNumberSP);
    final serverIp = ref.watch(networkDiscoveryClientServerIpProvider);

    useEffect(() {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
      ]);

      return () {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
        ]);
      };
    }, []);

    Widget renderDiscoveryOrDeviceHostSocket() {
      if (serverIp == null) {
        return const Center(child: Text('Seleziona un manager per continuare'));
      }

      if (deviceNumber == null) {
        return const Center(child: Text('Nome dispositivo non impostato!'));
      }

      return DeviceClientSocket(
        serverIp: serverIp,
        deviceName: deviceNumber,
      );
    }

    return WillPopScope(
      onWillPop: () async {
        if (serverIp != null) {
          ref.read(socketClientSP).stopConnection();
        }
        ref.invalidate(socketClientSP);
        ref.invalidate(clientMessagesSP);
        ref.invalidate(isConnectedSocketClientSP);
        ref.invalidate(myVrPlayerProvider);
        Logger.log('Disposed all providers for Device Client Screen');
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Device Host'),
          backgroundColor: Colors.black,
        ),
        backgroundColor: Colors.black,
        body: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('IP: $deviceIp'),
                Text('Server IP: ${serverIp ?? 'Nessun server trovato'}'),
                Text('Nome: $deviceNumber'),
              ],
            ),
            renderDiscoveryOrDeviceHostSocket(),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vr_trip/providers/device_ip_state/device_ip_state_provider.dart';
import 'package:vr_trip/providers/network_discovery/network_discovery_provider.dart';
import 'package:vr_trip/providers/settings_provider.dart';
import 'package:vr_trip/providers/socket_client/socket_client_provider.dart';
import 'package:vr_trip/screens/device_client/widgets/device_client_socket/device_client_socket.dart';

class DeviceClientScreen extends HookConsumerWidget {
  const DeviceClientScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceIp = ref.watch(deviceIpStateProvider);
    final deviceNumber = ref.watch(deviceNumberSP);
    final serverIp = ref.watch(networkDiscoveryClientServerIpProvider);

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Host'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          onPressed: () {
            if (serverIp != null) {
              ref.read(socketClientSP).stopConnection();
            }
            context.pop();
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text('IP: ${deviceIp}'),
              Text('Nome: ${deviceNumber}'),
            ],
          ),
          Text('Server IP: ${serverIp ?? 'Nessun server trovato'}'),
          renderDiscoveryOrDeviceHostSocket(),
        ],
      ),
    );
  }
}

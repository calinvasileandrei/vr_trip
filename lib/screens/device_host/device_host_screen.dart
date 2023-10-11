import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vr_trip/screens/device_host/widgets/device_host_socket/device_host_socket.dart';
import 'package:vr_trip/services/network_discovery_client/network_discovery_client.dart';

class DeviceHostScreen extends HookConsumerWidget {
  const DeviceHostScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverIp = ref.watch(networkDiscoveryClientServerIpProvider);

    renderDiscoveryOrDeviceHostSocket() {
      if (serverIp == null) {
        return const Center(child: Text('Discovery is running'));
      }
      return DeviceHostSocket(serverIp: serverIp);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Host'),
        actions: [
          Text('Server IP: ${serverIp ?? 'No server found'}'),
        ],
      ),
      body: renderDiscoveryOrDeviceHostSocket(),
    );
  }
}

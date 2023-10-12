import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vr_trip/screens/device_client/widgets/device_client_socket/device_client_socket.dart';
import 'package:vr_trip/services/device_ip_state_provider/device_ip_state_provider.dart';
import 'package:vr_trip/services/network_discovery_client/network_discovery_client.dart';

class DeviceClientScreen extends HookConsumerWidget {
  const DeviceClientScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceIp = ref.watch(deviceIpStateProvider);
    final serverIp =
        ref.watch(networkDiscoveryClientServerIpProvider(deviceIp!));

    Widget renderDiscoveryOrDeviceHostSocket() {
      if (serverIp == null) {
        return const Center(child: Text('Discovery is running'));
      }
      return DeviceClientSocket(
        serverIp: serverIp,
      );
    }

    handleRefresh() {
      ref
          .read(networkDiscoveryClientServerIpProvider(deviceIp).notifier)
          .state = null;
      ref.read(networkDiscoveryClientProvider(deviceIp)).resetServerIp();
      ref.read(networkDiscoveryClientProvider(deviceIp)).initService();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Host'),
        actions: [
          IconButton(
            onPressed: () {
              handleRefresh();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: Text('Server IP: ${serverIp ?? 'No server found'}'),
          ),
          renderDiscoveryOrDeviceHostSocket(),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vr_trip/providers/settings_provider.dart';
import 'package:vr_trip/screens/device_client/widgets/device_client_socket/device_client_socket.dart';
import 'package:vr_trip/services/device_ip_state_provider/device_ip_state_provider.dart';
import 'package:vr_trip/services/network_discovery_client/network_discovery_client.dart';
import 'package:vr_trip/services/network_discovery_client/network_discovery_client_provider.dart';

class DeviceClientScreen extends HookConsumerWidget {
  const DeviceClientScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceIp = ref.watch(deviceIpStateProvider);
    final deviceNumber = ref.watch(deviceNumberSP);
    final serverIp =
        ref.watch(networkDiscoveryClientServerIpProvider(deviceIp!));

    Widget renderDiscoveryOrDeviceHostSocket() {
      if (serverIp == null) {
        return const Center(child: Text('Discovery is running'));
      }

      if (deviceNumber == null) {
        return const Center(child: Text('Device number is not set'));
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
        leading: IconButton(
          onPressed: () {
            if (serverIp != null) {
              ref.read(socketClientSP(serverIp)).stopConnection();
              context.pop();
            }
          },
          icon: const Icon(Icons.arrow_back),
        ),
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
            child: Column(
              children: [
                Text('Server IP: ${serverIp ?? 'No server found'}'),
                Text('Device IP: ${deviceIp}'),
                Text('Device Number: ${deviceNumber}')
              ],
            ),
          ),
          renderDiscoveryOrDeviceHostSocket(),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:vr_trip/providers/socket_server_service_provider.dart';
import 'package:vr_trip/shared/socket_chat/socket_chat.dart';

class DeviceManagementScreen extends HookConsumerWidget {
  const DeviceManagementScreen({super.key});

  Future<String?> getWifiIp() async {
    final info = NetworkInfo();
    return await info.getWifiIP();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final socketConnections = ref.watch(serverConnectionsSP);
    final serverIp = useFuture(getWifiIp());

    renderIp() {
      if (serverIp.hasData) {
        return Text('Device Server IP: ${serverIp.data}');
      } else if (serverIp.hasError) {
        return const Text('Device Server IP: Error getting IP');
      } else {
        return const Text('Device Server IP: Loading...');
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Manager'),
      ),
      body: Column(
        children: [
          renderIp(),
          socketConnections.when(
            loading: () => const Text('Awaiting host connections...'),
            error: (error, stackTrace) => Text(error.toString()),
            data: (connections) {
              // Display all the messages in a scrollable list view.
              return SocketChat(items: connections);
            },
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:vr_trip/models/socket_types.dart';
import 'package:vr_trip/services/socket_server/socket_server_service.dart';
import 'package:vr_trip/shared/socket_chat/socket_chat.dart';

final socketServerSP = Provider.autoDispose<SocketServerService>((ref) {
  final service = SocketServerService();
  service.startSocketServer();
  service.connectionStream();

  ref.onDispose(() => service.stopSocketServer());

  return service;
});

final serverMessagesSP = StreamProvider.autoDispose<List<MySocketMessage>>(
    (ref) => ref.watch(socketServerSP).getMessages());

final serverConnectionsSP = StreamProvider.autoDispose<List<String>>(
    (ref) => ref.watch(socketServerSP).getConnections());

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
          ElevatedButton(
            onPressed: () {
              ref.read(socketServerSP).stopSocketServer();
            },
            child: Text('Stop Server'),
          ),
          socketConnections.when(
            loading: () => const Text('Awaiting host connections...'),
            error: (error, stackTrace) => Text(error.toString()),
            data: (connections) {
              // Display all the messages in a scrollable list view.
              return Center(child: SocketChat(items: connections));
            },
          ),
        ],
      ),
    );
  }
}

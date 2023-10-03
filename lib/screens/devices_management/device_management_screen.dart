import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vr_trip/providers/socket_manager/socket_manager_provider.dart';
import 'package:vr_trip/services/socket_server/socket_server_service.dart';
import 'package:vr_trip/shared/socket_chat/socket_chat.dart';

class DeviceManagementScreen extends HookConsumerWidget {
  const DeviceManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final socketServer = ref.watch(socketServerProvider);
    final messages = useState<List<String>>([]);
    final socketManager = ref.watch(socketManagerProvider);

    void addMessage(String value) {
      final currentList = List<String>.from(messages.value);
      currentList.add(value);
      messages.value = currentList;
    }

    useEffect(() {
      socketServer.startSocketServer();
      return () {
        socketServer.stopSocketServer();
      };
    }, const []);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Manager'),
      ),
      body: Center(
          child: Column(
        children: [
          Text(
              'Socket server : ${socketManager.isActive ? 'active' : 'stopped'}'),
          ElevatedButton(
            onPressed: () {
              if (!socketManager.isActive) {
                socketServer.startSocketServer();
              } else {
                socketServer.stopSocketServer();
              }
            },
            child: Text(
                '${socketManager.isActive ? 'Stop socket' : 'Active socket'}'),
          ),
          SocketChat(items: socketManager.getDevices),
          SocketChat(items: messages.value),
        ],
      )),
    );
  }
}

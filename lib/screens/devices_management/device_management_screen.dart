import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vr_trip/services/socket_server/socket_server_service.dart';
import 'package:vr_trip/shared/socket_chat/socket_chat.dart';

final devicesProvider = Provider<int>((ref) => 0);

enum DeviceType { advertiser, browser }

class DeviceManagementScreen extends HookConsumerWidget {
  const DeviceManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final socketServer = useMemoized(() => SocketServerService.instance);
    final devices = useState<List<String>>([]);
    final messages = useState<List<String>>([]);
    final isActive = ref.watch(socketServerProvider);

    void addMessage(String value) {
      final currentList = List<String>.from(messages.value);
      currentList.add(value);
      messages.value = currentList;
    }

    void addItem(String value) {
      final currentList = List<String>.from(devices.value);
      currentList.add(value);
      devices.value = currentList;
    }

    void removeItem(String name) {
      final currentList = List<String>.from(devices.value);
      currentList.remove(name);
      devices.value = currentList;
    }

    useEffect(() {
      socketServer.startSocketServer(ref);

      return () {
        socketServer.stopSocketServer(ref);
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
              'Socket server : ${isActive ? 'active' : 'stopped'}'),
          ElevatedButton(
            onPressed: () {
              socketServer.stopSocketServer(ref);
            },
            child: Text('Stop server'),
          ),
          SocketChat(items: devices.value),
          SocketChat(items: messages.value),
        ],
      )),
    );
  }
}

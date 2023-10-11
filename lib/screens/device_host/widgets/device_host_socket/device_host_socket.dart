import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vr_trip/services/socket_host/socket_host_service.dart';
import 'package:vr_trip/shared/socket_chat/socket_chat.dart';

final socketHostSP =
    Provider.family<SocketHostService, String>((ref, serverIp) {
  final service = SocketHostService(host: 'http://$serverIp', port: 3000);
  service.initConnection();
  service.startConnection();

  ref.onDispose(() => service.stopConnection());

  return service;
});

final hostMessagesSP = StreamProvider.autoDispose.family<List<String>, String>(
    (ref, serverIp) => ref.watch(socketHostSP(serverIp)).getMessages());

class DeviceHostSocket extends HookConsumerWidget {
  final String serverIp;

  const DeviceHostSocket({super.key, required this.serverIp});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(hostMessagesSP(serverIp));

    return Center(
        child: Column(
      children: [
        Text('Server : $serverIp'),
        ElevatedButton(
          onPressed: () {
            ref
                .read(socketHostSP(serverIp))
                .sendMessage('Hello from device host');
          },
          child: Text('Send Message to Server'),
        ),
        Container(
          color: Colors.blueGrey[300],
          child: messages.when(
            loading: () => const Text('Awaiting messages from server...'),
            error: (error, stackTrace) => Text(error.toString()),
            data: (messagesItems) {
              // Display all the messages in a scrollable list view.
              return SocketChat(items: messagesItems);
            },
          ),
        ),
      ],
    ));
  }
}

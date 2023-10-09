import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vr_trip/providers/socket_host_service_provider.dart';
import 'package:vr_trip/shared/socket_chat/socket_chat.dart';

class DeviceHostScreen extends HookConsumerWidget {
  const DeviceHostScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(hostMessagesSP);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Host'),
      ),
      body: Center(
          child: Column(
        children: [
          Text('Device Host Screen'),
          ElevatedButton(
            onPressed: () {
              ref.read(socketHostSP).sendMessage('Hello from device host');
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
      )),
    );
  }
}

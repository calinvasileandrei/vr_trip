import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vr_trip/providers/socket_service_provider.dart';
import 'package:vr_trip/shared/socket_chat/socket_chat.dart';

class DeviceManagementScreen extends HookConsumerWidget {
  const DeviceManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final socketConnections = ref.watch(connectionsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Manager'),
      ),
      body: socketConnections.when(
        loading: () => const Text('Loading...'),
        error: (error, stackTrace) => Text(error.toString()),
        data: (connections) {
          // Display all the messages in a scrollable list view.
          return SocketChat(items: connections);
        },
      ),
    );
  }
}

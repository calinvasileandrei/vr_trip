import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vr_trip/models/library_item_model.dart';
import 'package:vr_trip/models/socket_protocol_message.dart';
import 'package:vr_trip/screens/devices_management/widgets/remote_video_action_bar/remote_video_action_bar.dart';
import 'package:vr_trip/screens/devices_management/widgets/server_action_bar/server_action_bar.dart';
import 'package:vr_trip/services/device_ip_state_provider/device_ip_state_provider.dart';
import 'package:vr_trip/services/network_discovery_server/network_discovery_server_provider.dart';
import 'package:vr_trip/shared/socket_chat/socket_chat.dart';
import 'package:vr_trip/shared/vr_video_library/vr_video_library_component.dart';

class DeviceManagementScreen extends HookConsumerWidget {
  const DeviceManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceIp = ref.watch(deviceIpStateProvider);
    final socketConnections = ref.watch(serverConnectionsSP);
    final discovery = ref.watch(networkDiscoveryServerSP);

    void handleItemSelected(LibraryItemModel item) {
      ref
          .read(socketServerSP)
          .sendBroadcastMessage(SocketActionTypes.selectVideo, item.path);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Manager'),
      ),
      body: Column(
        children: [
          Text('Device Server IP: ${deviceIp}'),
          Text('DiscoveryServer Status: ${discovery.getStatus().name}'),
          ServerActionBar(),
          socketConnections.when(
            loading: () => const Text('Awaiting host connections...'),
            error: (error, stackTrace) => Text(error.toString()),
            data: (connections) {
              // Display all the messages in a scrollable list view.
              return Center(
                  child: SocketChat(
                items: connections,
              ));
            },
          ),
          VrVideoLibrary(onItemPress: handleItemSelected),
          RemoteVideoActionBar(),
        ],
      ),
    );
  }
}

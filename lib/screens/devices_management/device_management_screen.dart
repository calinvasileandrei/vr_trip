import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vr_trip/models/library_item_model.dart';
import 'package:vr_trip/models/socket_protocol_message.dart';
import 'package:vr_trip/services/device_ip_state_provider/device_ip_state_provider.dart';
import 'package:vr_trip/services/network_discovery_server/network_discovery_server.dart';
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  final status = ref.read(networkDiscoveryServerSP).getStatus();
                  if (status == NetworkDiscoveryServerStatus.online) {
                    ref.read(networkDiscoveryServerSP).startBroadcast();
                  } else {
                    ref.read(networkDiscoveryServerSP).stopBroadcast();
                  }
                },
                child: Text('Toggle Discovery Server'),
              ),
              ElevatedButton(
                onPressed: () {
                  ref.read(socketServerSP).stopSocketServer();
                },
                child: Text('Stop Server'),
              ),
            ],
          ),
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
          Expanded(child: VrVideoLibrary(onItemPress: handleItemSelected)),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: () {}, child: Icon(Icons.arrow_back_ios)),
                ElevatedButton(
                    onPressed: () {
                      ref
                          .read(socketServerSP)
                          .sendBroadcastMessage(SocketActionTypes.play, '');
                    },
                    child: Icon(Icons.play_arrow)),
                ElevatedButton(
                    onPressed: () {
                      ref
                          .read(socketServerSP)
                          .sendBroadcastMessage(SocketActionTypes.pause, '');
                    },
                    child: Icon(Icons.pause)),
                ElevatedButton(
                    onPressed: () {}, child: Icon(Icons.arrow_forward_ios)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

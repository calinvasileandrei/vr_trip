import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:vr_trip/models/library_item_model.dart';
import 'package:vr_trip/models/socket_protocol_message.dart';
import 'package:vr_trip/services/network_discovery_server/network_discovery_server.dart';
import 'package:vr_trip/services/network_discovery_server/network_discovery_server_provider.dart';
import 'package:vr_trip/shared/socket_chat/socket_chat.dart';
import 'package:vr_trip/shared/vr_video_library/vr_video_library_component.dart';

class DeviceManagementScreen extends HookConsumerWidget {
  const DeviceManagementScreen({super.key});

  Future<String?> getWifiIp() async {
    final info = NetworkInfo();
    return await info.getWifiIP();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final socketConnections = ref.watch(serverConnectionsSP);
    final discovery = ref.watch(networkDiscoveryServerSP);
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
          renderIp(),
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
          VrVideoLibrary(onItemPress: handleItemSelected),
        ],
      ),
    );
  }
}

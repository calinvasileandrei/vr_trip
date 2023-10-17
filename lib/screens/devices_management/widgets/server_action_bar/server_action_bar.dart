import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vr_trip/providers/discoveryService/discoveryService_provider.dart';
import 'package:vr_trip/providers/socket_server/socket_server_provider.dart';
import 'package:vr_trip/services/network_discovery_server/network_discovery_server.dart';

class ServerActionBar extends HookConsumerWidget {
  const ServerActionBar({super.key});

  void toggleDiscovery(WidgetRef ref) {
    final status = ref.read(discoveryServiceStatusSP);
    if (status == NetworkDiscoveryServerStatus.online) {
      ref.read(networkDiscoveryServerSP).initService();
    } else {
      ref.read(networkDiscoveryServerSP).stopService();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () => toggleDiscovery(ref),
          child: Text('Toggle Discovery Server'),
        ),
        ElevatedButton(
          onPressed: () {
            ref.read(socketServerSP).stopSocketServer();
          },
          child: Text('Stop Server'),
        ),
      ],
    );
  }
}

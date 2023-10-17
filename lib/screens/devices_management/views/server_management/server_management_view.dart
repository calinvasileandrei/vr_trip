import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vr_trip/screens/devices_management/widgets/server_action_bar/server_action_bar.dart';
import 'package:vr_trip/services/device_ip_state_provider/device_ip_state_provider.dart';
import 'package:vr_trip/providers/socket_server/socket_server_provider.dart';
import 'package:vr_trip/shared/socket_clients/socket_clients.dart';

class ServerManagementView extends HookConsumerWidget {
  const ServerManagementView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final socketConnections = ref.watch(serverConnectionsSP);
    final deviceIp = ref.watch(deviceIpStateProvider);
    final discovery = ref.watch(networkDiscoveryServerSP);

    initBroadCast() async {
      await discovery.initService();
      await discovery.startBroadcast();
    }

    useEffect(() {
      initBroadCast();
    }, []);

    return Center(
      child: Column(
        children: [
          Text('Device Server IP: ${deviceIp}'),
          Text('DiscoveryServer Status: ${discovery.getStatus().name}'),
          const ServerActionBar(),
          socketConnections.when(
            loading: () => const Text('Awaiting client connections...'),
            error: (error, stackTrace) => Text(error.toString()),
            data: (connections) {
              // Display all the messages in a scrollable list view.
              return Center(
                  child: SocketClients(
                items: connections,
              ));
            },
          )
        ],
      ),
    );
  }
}

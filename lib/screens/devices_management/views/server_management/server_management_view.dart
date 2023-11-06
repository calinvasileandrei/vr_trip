import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vr_trip/providers/device_ip_state/device_ip_state_provider.dart';
import 'package:vr_trip/providers/discoveryService/discoveryService_provider.dart';
import 'package:vr_trip/providers/socket_server/socket_server_provider.dart';
import 'package:vr_trip/screens/devices_management/widgets/server_action_bar/server_action_bar.dart';
import 'package:vr_trip/shared/socket_clients/socket_clients.dart';

class ServerManagementView extends HookConsumerWidget {
  const ServerManagementView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final socketConnections = ref.watch(serverConnectionsSP);
    final deviceIp = ref.watch(deviceIpStateProvider);
    final discovery = ref.watch(networkDiscoveryServerSP);
    final discoveryServiceStatus = ref.watch(discoveryServiceStatusSP);

    useEffect(() {
      discovery.initService();
      return null;
    }, []);

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('IP: ${deviceIp}'),
                Text('Ricerca device: ${discoveryServiceStatus.name}'),
              ],
            ),

            const ServerActionBar(),
            socketConnections.when(
              loading: () => Expanded(child: Center(child: const Text('In attesa di device...'))),
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
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vr_trip/providers/device_ip_state/device_ip_state_provider.dart';
import 'package:vr_trip/providers/network_discovery/network_discovery_provider.dart';

class SelectManagerScreen extends HookConsumerWidget {
  const SelectManagerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceIp = ref.watch(deviceIpStateProvider);
    final possibleManagersAsyncs = ref.watch(possibleManagerSP(deviceIp!));
    final serverIp = ref.watch(networkDiscoveryClientServerIpProvider);
    final List<String> possibleManagersList = possibleManagersAsyncs.maybeWhen(
        data: (value) => value, orElse: () => []);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Selezione Manager'),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Container(
        margin: const EdgeInsets.symmetric(vertical: 40, horizontal: 10),
        child: Column(
          children: [
            Container(
                height: 50,
                width: double.infinity,
                color: Theme.of(context).colorScheme.background,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child:
                            Text('Server IP: ${serverIp ?? 'Nessun server'}')),
                    IconButton(
                        onPressed: () {
                          ref
                              .read(networkDiscoveryClientServerIpProvider
                                  .notifier)
                              .state = null;
                        },
                        icon: Icon(
                          Icons.delete,
                          color: Theme.of(context).colorScheme.error,
                        ))
                  ],
                )),
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(vertical: 20),
                color: Theme.of(context).colorScheme.background,
                child: possibleManagersList.isEmpty
                    ? const Center(child: Text('Ricerca di un manager in corso...'))
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: possibleManagersList.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              ref
                                  .read(networkDiscoveryClientServerIpProvider
                                      .notifier)
                                  .state = possibleManagersList[index];
                              //context.go('/device-client');
                            },
                            child: Container(
                                height: 50,
                                color: Theme.of(context).colorScheme.surface,
                                margin: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: const Icon(Icons.ad_units)),
                                    Text(possibleManagersList[index]),
                                  ],
                                )),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

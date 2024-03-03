import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:vr_trip/providers/device_ip_state/device_ip_state_provider.dart';
import 'package:vr_trip/router/routes.dart';
import 'package:vr_trip/shared/ui_kit/my_button/my_button_component.dart';

class HomeScreen extends HookConsumerWidget {
  HomeScreen({super.key});

  Future<String?> getWifiIp() async {
    final info = NetworkInfo();
    return await info.getWifiIP();
  }

  final List<Function> customFunctions = [
    () => AppRoutes.deviceManagement.name,
    () => AppRoutes.selectManager.name,
    () => AppRoutes.deviceHost.name,
    () => AppRoutes.fileManager.name,
    () => AppRoutes.settings.name,
  ];

  final List<Map<String, dynamic>> data = [
    {
      "route": AppRoutes.deviceManagement.name,
      "icon": Icons.wifi,
      "label": "Device Manager",
    },
    {
      "route": AppRoutes.deviceHost.name,
      "icon": Icons.person_outline,
      "label": "Device Client",
    },
    {
      "route": AppRoutes.selectManager.name,
      "icon": Icons.account_tree,
      "label": "Selezione Manager",
    },
    {
      "route": AppRoutes.fileManager.name,
      "icon": Icons.file_copy,
      "label": "Gestione File",
    },
    {
      "route": AppRoutes.settings.name,
      "icon": Icons.settings,
      "label": "Settings",
    }
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ip = ref.watch(deviceIpStateProvider);

    useEffect(() {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
      getWifiIp().then((ip) {
        ref.read(deviceIpStateProvider.notifier).state = ip;
      });

      return null;
    }, []);

    Widget renderIp() {
      if (ip != null) {
        return Container(
          margin: const EdgeInsets.all(20.0),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
            ),
            itemBuilder: (BuildContext context, int index) {
              return InkWell(
                onTap: () {
                  // Use the index of the container to call the corresponding function.
                  final route = data[index]['route'];
                  context.goNamed(route);
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white10, width: 1.0),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          data[index]['icon'],
                          size: 100,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        Text(
                          '${data[index]['label']}',
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            itemCount: customFunctions.length,
          ),
        );
      } else {
        return Container(
          margin: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const Text('Device IP non trovato...'),
              MyButton('Aggiorna', onPressed: (){
                getWifiIp().then((ip) {
                  ref.read(deviceIpStateProvider.notifier).state = ip;
                });
              })
            ],
          ),
        );
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('VR Trip'),
      ),
      body: renderIp(),
    );
  }
}

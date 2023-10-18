import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:vr_trip/providers/device_ip_state/device_ip_state_provider.dart';
import 'package:vr_trip/router/routes.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  Future<String?> getWifiIp() async {
    final info = NetworkInfo();
    return await info.getWifiIP();
  }

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
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                  onPressed: () => {
                        context.goNamed(AppRoutes.deviceManagement.name),
                      },
                  child: const Text('navigate to device management screen')),
              ElevatedButton(
                  onPressed: () => {
                        context.goNamed(AppRoutes.deviceHost.name),
                      },
                  child: const Text('navigate to device host screen')),
              ElevatedButton(
                  onPressed: () => {
                        context.goNamed(AppRoutes.fileManager.name),
                      },
                  child: const Text('navigate to File manager screen')),
              ElevatedButton(
                  onPressed: () => {
                    context.goNamed(AppRoutes.settings.name),
                  },
                  child: const Text('navigate to Settings screen')),
            ],
          ),
        );
      } else {
        return const Text('Device IP: Loading...');
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('VR Trip'),
      ),
      body: renderIp(),
    );
  }
}

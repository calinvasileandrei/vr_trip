import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vr_trip/screens/device_host/device_host_screen.dart';
import 'package:vr_trip/screens/devices_management/device_management_screen.dart';
import 'package:vr_trip/screens/file_manager/file_manager_screen.dart';
import 'package:vr_trip/screens/vr_player/vr_player_screen.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('VR Trip'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
                onPressed: () => {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const DeviceManagementScreen()))
                    },
                child: const Text('navigate to device management screen')),
            ElevatedButton(
                onPressed: () => {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const DeviceHostScreen()))
                    },
                child: const Text('navigate to device host screen')),
            ElevatedButton(
                onPressed: () => {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const VrPlayerScreen(
                                    videoPath:
                                        '/data/user/0/com.calinvasileandrei.vr_trip/app_flutter/demovr.mp4',
                                  )))
                    },
                child: const Text('navigate to VR Player screen')),
            ElevatedButton(
                onPressed: () => {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const FileManagerScreen()))
                    },
                child: const Text('navigate to File manager screen')),
          ],
        ),
      ),
    );
  }
}

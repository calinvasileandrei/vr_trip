import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vr_trip/screens/device_host/device_host_screen.dart';
import 'package:vr_trip/screens/file_manager/file_manager_screen.dart';
import 'package:vr_trip/screens/vr_player/vr_player_screen.dart';
import 'package:vr_trip/utils/logger.dart';

import 'screens/devices_management/device_management_screen.dart';

void main() {
  runApp(
    const ProviderScope(child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'VR Trip'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void askPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.manageExternalStorage,
      Permission.storage,
      Permission.photos,
      Permission.accessMediaLocation,
      Permission.mediaLibrary,
      Permission.videos,
      Permission.audio,
    ].request();
    statuses.forEach((key, value) {
      Logger.log('permission key: $key, value: $value');
    });
  }

  @override
  void initState() {
    super.initState();
    // Ask app permissions
    askPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
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

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vr_trip/router/router.dart';
import 'package:vr_trip/screens/home/home_screen.dart';
import 'package:vr_trip/utils/logger.dart';

void main() {
  runApp(
    ProviderScope(child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'VR Trip',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      routerDelegate: appRouter.routerDelegate,
      routeInformationParser: appRouter.routeInformationParser,
      routeInformationProvider: appRouter.routeInformationProvider,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

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
    return const HomeScreen();
  }
}

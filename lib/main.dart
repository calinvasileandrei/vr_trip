import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hooked_bloc/hooked_bloc.dart';
import 'package:vr_trip/cubits/socket_host/socket_host_cubit.dart';
import 'package:vr_trip/cubits/socket_manager/socket_manager_cubit.dart';
import 'package:vr_trip/screens/device_host/device_host_screen.dart';

import 'screens/devices_management/device_management_screen.dart';

void main() {
  runApp(HookedBlocConfigProvider(
    builderCondition: (state) => state != null, // Global build condition
    listenerCondition: (state) => state != null, // Global listen condition
    child: const MyApp(),
  ));
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
                              builder: (context) => BlocProvider(
                                    create: (context) => SocketManagerCubit(),
                                    child: DeviceManagementScreen(),
                                  )))
                    },
                child: const Text('navigate to device management screen')),
            ElevatedButton(
                onPressed: () => {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => BlocProvider(
                                    create: (context) => SocketHostCubit(),
                                    child: DeviceHostScreen(),
                                  )))
                    },
                child: const Text('navigate to device host screen')),
          ],
        ),
      ),
    );
  }
}

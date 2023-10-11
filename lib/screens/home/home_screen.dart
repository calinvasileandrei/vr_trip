import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vr_trip/router/routes.dart';

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
          ],
        ),
      ),
    );
  }
}

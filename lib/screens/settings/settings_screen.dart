import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vr_trip/providers/settings_provider.dart';
import 'package:vr_trip/services/settings/settings_service.dart';

class SettingsScreen extends HookConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceNumber = ref.watch(deviceNumberSP);
    final deviceNameController = useTextEditingController();

    handleSave() {
      ref.read(deviceNumberSP.notifier).state = deviceNameController.text;
      saveDeviceNumberToPrefs(deviceNameController.text);
      Navigator.pop(context);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Container(
        margin: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(children: [
            Text('Device Number: $deviceNumber'),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 40, horizontal: 10),
              child: Column(
                children: [
                  TextField(
                    controller: deviceNameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Set new Device Number',
                    ),
                  ),
                  ElevatedButton(onPressed: handleSave, child: const Text('Save'))

                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

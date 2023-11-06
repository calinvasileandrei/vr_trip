import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vr_trip/providers/settings_provider.dart';
import 'package:vr_trip/services/settings/settings_service.dart';
import 'package:vr_trip/shared/ui_kit/my_button/my_button_component.dart';

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

    useEffect(() {
      if (deviceNumber != null) {
        deviceNameController.text = deviceNumber;
      }
    }, []);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Container(
        color: Theme.of(context).colorScheme.surface,
        child: Column(children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 40, horizontal: 10),
            child: Column(
              children: [
                TextField(
                  controller: deviceNameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Nome Dispositivo',
                  ),
                ),
                MyButton('Salva', onPressed: handleSave),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vr_trip/screens/devices_management/views/library_chooser/library_chooser_view.dart';
import 'package:vr_trip/screens/devices_management/views/server_management/server_management_view.dart';
import 'package:vr_trip/screens/devices_management/views/video_preview/video_preview_view.dart';
import 'package:vr_trip/screens/devices_management/widgets/remote_video_action_bar/remote_video_action_bar.dart';
import 'package:vr_trip/shared/my_snap_view/my_snap_view.dart';

class DeviceManagementScreen extends HookConsumerWidget {
  const DeviceManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Manager'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: const Column(
        children: [
          MySnapView(children: [
            ServerManagementView(),
            LibraryChooserView(),
            VideoPreviewView(),
          ]),
          RemoteVideoActionBar(),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vr_trip/providers/device_manager/device_manager_provider.dart';
import 'package:vr_trip/providers/my_vr_player/my_vr_player_provider.dart';
import 'package:vr_trip/providers/socket_server/socket_server_provider.dart';
import 'package:vr_trip/screens/devices_management/views/library_chooser/library_chooser_view.dart';
import 'package:vr_trip/screens/devices_management/views/server_management/server_management_view.dart';
import 'package:vr_trip/screens/devices_management/views/video_preview/video_preview_view.dart';
import 'package:vr_trip/screens/devices_management/widgets/remote_video_action_bar/remote_video_action_bar.dart';
import 'package:vr_trip/shared/keep_alive_page/keep_alive_page.dart';
import 'package:vr_trip/shared/my_snap_view/my_snap_view.dart';
import 'package:vr_trip/utils/logger.dart';

class DeviceManagementScreen extends HookConsumerWidget {
  const DeviceManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var deviceManager = ref.watch(deviceManagerProvider);
    var selectedLibraryItem = deviceManager.selectedLibraryItem;

    return WillPopScope(
      onWillPop: () async {
        ref.invalidate(deviceManagerProvider);
        ref.invalidate(videoPreviewEventSP);

        ref.invalidate(serverMessagesSP);
        ref.invalidate(serverConnectionsSP);
        ref.invalidate(socketServerSP);
        ref.invalidate(networkDiscoveryServerSP);
        ref.invalidate(myVrPlayerProvider);
        Logger.log('Disposed all providers for Device Management Screen');
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Device Manager'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Column(
          children: [
            Expanded(
              child: MySnapView(children: [
                const ServerManagementView(),
                const LibraryChooserView(),
                KeepAlivePage(
                    keepPageAlive: selectedLibraryItem != null,
                    child:
                        const VideoPreviewView() // Keep the page alive only if a video is selected
                    ),
              ]),
            ),
            const RemoteVideoActionBar(),
          ],
        ),
      ),
    );
  }
}

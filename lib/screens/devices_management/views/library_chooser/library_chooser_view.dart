import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vr_trip/models/library_item_model.dart';
import 'package:vr_trip/models/socket_protocol_message.dart';
import 'package:vr_trip/providers/device_manager/device_manager_provider.dart';
import 'package:vr_trip/providers/my_vr_player/my_vr_player_provider.dart';
import 'package:vr_trip/providers/socket_server/socket_server_provider.dart';
import 'package:vr_trip/shared/vr_video_library/vr_video_library_component.dart';

class LibraryChooserView extends HookConsumerWidget {
  const LibraryChooserView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var deviceManager = ref.watch(deviceManagerProvider);
    var selectedLibraryItem= deviceManager.selectedLibraryItem;

    void handleItemSelected(LibraryItemModel item) {
      if(selectedLibraryItem == null){
        ref
            .read(socketServerSP)
            .sendBroadcastMessage(SocketActionTypes.selectVideo, item.path);
        ref.read(deviceManagerProvider.notifier).setSelectedLibraryItem(item);
      }
    }

    Widget renderButton() {
      return (IconButton(
        onPressed: () {
          ref.read(deviceManagerProvider.notifier).setSelectedLibraryItem(null);
          ref.read(myVrPlayerProvider.notifier).setLibraryItem(null);
          ref.invalidate(myVrPlayerProvider);
          ref
              .read(socketServerSP)
              .sendBroadcastMessage(SocketActionTypes.selectVideo, 'no_video');
        },
        icon: const Icon(Icons.delete, color: Colors.black),
      ));
    }

    return Container(
      color: Theme.of(context).colorScheme.inversePrimary,

      child: VrVideoLibrary(
          onItemPress: handleItemSelected,
          disableDeleteButton: true,
          selectedLibraryItem: selectedLibraryItem,
          customEndingHeader: renderButton),
    );
  }
}

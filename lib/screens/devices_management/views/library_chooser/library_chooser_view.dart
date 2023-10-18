import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vr_trip/models/library_item_model.dart';
import 'package:vr_trip/models/socket_protocol_message.dart';
import 'package:vr_trip/providers/socket_server/socket_server_provider.dart';
import 'package:vr_trip/shared/vr_video_library/vr_video_library_component.dart';

class LibraryChooserView extends HookConsumerWidget {
  const LibraryChooserView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void handleItemSelected(LibraryItemModel item) {
      ref
          .read(socketServerSP)
          .sendBroadcastMessage(SocketActionTypes.selectVideo, item.path);
    }

    return Flex(
        direction: Axis.vertical,
        children: [VrVideoLibrary(onItemPress: handleItemSelected)]);
  }
}

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
          .sendBroadcastMessage(SocketActionTypes.selectVideo, item.videoPath);
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        color: Theme.of(context).colorScheme.surface,
        boxShadow: const [
          BoxShadow(
            color: Colors.white24,
            offset: Offset(0.0, 1.0), //(x,y)
            blurRadius: 12.0,
          ),
        ],
      ),
      child: Flex(
          direction: Axis.vertical,
          children: [
            Container(
                margin: const EdgeInsets.symmetric(vertical: 20),
                child: const Text('Video Library', style: TextStyle(fontSize: 20))),
            VrVideoLibrary(onItemPress: handleItemSelected)]),
    );
  }
}

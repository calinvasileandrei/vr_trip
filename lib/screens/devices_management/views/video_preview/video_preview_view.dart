import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vr_trip/models/library_item_model.dart';
import 'package:vr_trip/providers/device_manager/device_manager_provider.dart';
import 'package:vr_trip/screens/devices_management/views/video_preview/widget/transcript_preview/transcript_preview.dart';
import 'package:vr_trip/screens/devices_management/views/video_preview/widget/vr_player_previewer/vr_player_previewer.dart';

class VideoPreviewView extends HookConsumerWidget {
  const VideoPreviewView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libraryItemPath = ref.watch(selectedLibraryItemSP);

    Widget getTranscriptPreview(TranscriptObject? transcriptObject) {
      if (transcriptObject == null) return Container();
      return (
        Column(
          children: [
            const Text('Transcript Preview'),
            Text('Nome Video: ${transcriptObject.nomeVideo}'),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 5),
              height: MediaQuery.of(context).size.height /2.27 ,
              width: MediaQuery.of(context).size.width,
              child: TranscriptPreview(transcriptObject: transcriptObject),
            )
          ],
        )
      );
    }

    return Column(
      children: [
    const Text('Remote Video Player'),
    if (libraryItemPath != null)
      Container(
        height: MediaQuery.of(context).size.width /2 ,
        width: MediaQuery.of(context).size.width,
        color: Colors.black,
        child: VrPlayerPreviewer(
          libraryItem: libraryItemPath,
        ),
      ),
      getTranscriptPreview(libraryItemPath?.transcriptObject)
      ],
    );
  }
}

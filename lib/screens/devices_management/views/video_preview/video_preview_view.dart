import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vr_trip/models/library_item_model.dart';
import 'package:vr_trip/providers/device_manager/device_manager_provider.dart';
import 'package:vr_trip/screens/devices_management/views/video_preview/widget/transcript_preview/transcript_preview.dart';
import 'package:vr_trip/screens/devices_management/views/video_preview/widget/vr_player_previewer/vr_player_previewer.dart';
import 'package:vr_trip/utils/logger.dart';

class VideoPreviewView extends HookConsumerWidget {
  const VideoPreviewView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libraryItemPath = ref.watch(selectedLibraryItemSP);

    onTimelineItemPress(TimelineItem timelineItem) {
      //TODO: Implement this
      Logger.log('onTimelineItemPress: $timelineItem');
      //ref.read(currentTimeLineItemSP.notifier).state = timelineItem;
      //ref.read(videoPreviewEventSP.notifier).state = VideoPreviewEvent.play;
    }

    Widget getTranscriptPreview(TranscriptObject? transcriptObject) {
      if (transcriptObject == null) return Container();
      return (Column(
        children: [
          const Text('Transcript Preview'),
          Text('Nome Video: ${transcriptObject.nomeVideo}'),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 5),
            height: MediaQuery.of(context).size.height / 2.27,
            width: MediaQuery.of(context).size.width,
            child: TranscriptPreview(
                transcriptObject: transcriptObject,
                onTimelineItemPress: onTimelineItemPress),
          )
        ],
      ));
    }

    return Column(
      children: [
        const Text('Remote Video Player'),
        if (libraryItemPath != null)
          VrPlayerPreviewer(
            libraryItem: libraryItemPath,
          )
        else
          Container(
              height: MediaQuery.of(context).size.width / 2,
              width: MediaQuery.of(context).size.width,
              color: Colors.black,
              child: const Center(
                child: Text('Nessun video selezionato',style: TextStyle(color: Colors.white) ),
              )),
        getTranscriptPreview(libraryItemPath?.transcriptObject)
      ],
    );
  }
}

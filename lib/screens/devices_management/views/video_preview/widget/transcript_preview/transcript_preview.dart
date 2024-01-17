import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vr_trip/models/library_item_model.dart';
import 'package:vr_trip/providers/device_manager/device_manager_provider.dart';

class TranscriptPreview extends HookConsumerWidget {
  final TranscriptObject transcriptObject;

  TranscriptPreview({super.key, required this.transcriptObject});

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    var currentTranscript = ref.watch(currentTimeLineItemSP);

    return ListView.builder(
      itemCount: transcriptObject.timeline.length ,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          child: Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide()),
            ),
            child: Row(
              children: [
                if (currentTranscript?.nomeClip == transcriptObject.timeline[index].nomeClip)
                  const Icon(Icons.play_arrow),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          transcriptObject.timeline[index].nomeClip),
                      Text(
                          'Inizio: ${transcriptObject.timeline[index].start} - Fine: ${transcriptObject.timeline[index].end}')
                    ],
                  ),
                )
              ],
            )
          ),
        );
      },
    );
  }
}

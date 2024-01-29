import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vr_trip/models/socket_protocol_message.dart';
import 'package:vr_trip/models/timeline_state_model.dart';
import 'package:vr_trip/providers/device_manager/device_manager_provider.dart';
import 'package:vr_trip/providers/device_manager/types.dart';
import 'package:vr_trip/providers/socket_server/socket_server_provider.dart';
import 'package:vr_trip/providers/my_vr_player/my_vr_player_provider.dart';
import 'package:vr_trip/utils/logger.dart';
import 'package:vr_trip/utils/vr_player_utils.dart';

const prefix = '[remote_video_action_bar]';

class RemoteVideoActionBar extends HookConsumerWidget {
  const RemoteVideoActionBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    TimelineStateModel? getTimelineItem(bool? isPrevious) {
      var currentTimelineItem = ref.read(currentTimeLineItemSP);
      var vrState = ref.read(myVrPlayerProvider);
      if (currentTimelineItem == null) return null;

      if (vrState.libraryItem != null) {
        if (isPrevious == true) {
          // get previous timeline item
          return VrPlayerUtils.getPreviousTimelineItem(currentTimelineItem,
              vrState.libraryItem!.transcriptObject.timeline);
        }
        // Next timeline item
        return VrPlayerUtils.getNextTimelineItem(currentTimelineItem,
            vrState.libraryItem!.transcriptObject.timeline);
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
              onPressed: () {
                TimelineStateModel? timeline = getTimelineItem(true);
                if (timeline == null) return;

                ref.read(socketServerSP).sendBroadcastMessage(
                    SocketActionTypes.backward, jsonEncode(timeline.toJson()));
                ref.read(videoPreviewEventSP.notifier).state =
                    VideoPreviewEvent.backward;
                Logger.log('$prefix Backward');
              },
              child: const Icon(Icons.arrow_back_ios)),
          ElevatedButton(
              onPressed: () {
                var seekPosition =
                    ref.read(myVrPlayerProvider).seekPosition.toInt();
                ref.read(socketServerSP).sendBroadcastMessage(
                    SocketActionTypes.play, seekPosition.toString());
                ref.read(videoPreviewEventSP.notifier).state =
                    VideoPreviewEvent.play;
                Logger.log('$prefix Play');
              },
              child: const Icon(Icons.play_arrow)),
          ElevatedButton(
              onPressed: () {
                var seekPosition =
                    ref.read(myVrPlayerProvider).seekPosition.toInt();
                ref.read(socketServerSP).sendBroadcastMessage(
                    SocketActionTypes.pause, seekPosition.toString());
                ref.read(videoPreviewEventSP.notifier).state =
                    VideoPreviewEvent.pause;
                Logger.log('$prefix Pause');
              },
              child: const Icon(Icons.pause)),
          ElevatedButton(
              onPressed: () {
                TimelineStateModel? timeline = getTimelineItem(false);
                if (timeline == null) return;
                ref.read(socketServerSP).sendBroadcastMessage(
                    SocketActionTypes.forward, jsonEncode(timeline.toJson()));
                ref.read(videoPreviewEventSP.notifier).state =
                    VideoPreviewEvent.forward;
                Logger.log('$prefix Forward');
              },
              child: const Icon(Icons.arrow_forward_ios)),
        ],
      ),
    );
  }
}

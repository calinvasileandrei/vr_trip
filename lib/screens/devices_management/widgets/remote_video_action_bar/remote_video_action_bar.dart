import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vr_trip/models/socket_protocol_message.dart';
import 'package:vr_trip/providers/device_manager/device_manager_provider.dart';
import 'package:vr_trip/providers/device_manager/types.dart';
import 'package:vr_trip/providers/socket_server/socket_server_provider.dart';
import 'package:vr_trip/utils/logger.dart';

const prefix = '[remote_video_action_bar]';
class RemoteVideoActionBar extends HookConsumerWidget {
  const RemoteVideoActionBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
              onPressed: () {
                ref
                    .read(socketServerSP)
                    .sendBroadcastMessage(SocketActionTypes.backward, '');
                ref.read(videoPreviewEventSP.notifier).state =
                    VideoPreviewEvent.backward;
                Logger.log('$prefix Backward');
              },
              child: const Icon(Icons.arrow_back_ios)),
          ElevatedButton(
              onPressed: () {
                ref
                    .read(socketServerSP)
                    .sendBroadcastMessage(SocketActionTypes.play, '');
                ref.read(videoPreviewEventSP.notifier).state =
                    VideoPreviewEvent.play;
                Logger.log('$prefix Play');
              },
              child: const Icon(Icons.play_arrow)),
          ElevatedButton(
              onPressed: () {
                ref
                    .read(socketServerSP)
                    .sendBroadcastMessage(SocketActionTypes.pause, '');
                ref.read(videoPreviewEventSP.notifier).state =
                    VideoPreviewEvent.pause;
                Logger.log('$prefix Pause');
              },
              child: const Icon(Icons.pause)),
          ElevatedButton(
              onPressed: () {
                ref
                    .read(socketServerSP)
                    .sendBroadcastMessage(SocketActionTypes.forward, '');
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

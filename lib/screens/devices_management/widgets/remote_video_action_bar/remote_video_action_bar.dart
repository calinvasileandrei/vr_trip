import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vr_trip/models/socket_protocol_message.dart';
import 'package:vr_trip/providers/socket_server/socket_server_provider.dart';

class RemoteVideoActionBar extends HookConsumerWidget {
  const RemoteVideoActionBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(onPressed: () {}, child: Icon(Icons.arrow_back_ios)),
          ElevatedButton(
              onPressed: () {
                ref
                    .read(socketServerSP)
                    .sendBroadcastMessage(SocketActionTypes.play, '');
              },
              child: Icon(Icons.play_arrow)),
          ElevatedButton(
              onPressed: () {
                ref
                    .read(socketServerSP)
                    .sendBroadcastMessage(SocketActionTypes.pause, '');
              },
              child: Icon(Icons.pause)),
          ElevatedButton(
              onPressed: () {}, child: Icon(Icons.arrow_forward_ios)),
        ],
      ),
    );
  }
}

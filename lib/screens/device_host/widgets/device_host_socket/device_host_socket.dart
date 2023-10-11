import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vr_trip/models/socket_protocol_message.dart';
import 'package:vr_trip/screens/vr_player/vr_player_screen.dart';
import 'package:vr_trip/services/network_discovery_client/network_discovery_client_provider.dart';
import 'package:vr_trip/services/socket_protocol/socket_protocol_service.dart';
import 'package:vr_trip/shared/socket_chat/socket_chat.dart';
import 'package:vr_trip/utils/logger.dart';

class DeviceHostSocket extends HookConsumerWidget {
  final String serverIp;

  const DeviceHostSocket({super.key, required this.serverIp});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(hostMessagesSP(serverIp));

    navigateWithVideo(String videoPath) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => VrPlayerScreen(
                    videoPath: videoPath,
                  )));
    }

    getLastMessage(List<String> messages) async {
      Logger.log('getLastMessage - messages: $messages');
      if (messages.isEmpty) return;

      final lastMessageIndex = messages.length - 1;
      final message = messages[lastMessageIndex];
      SocketAction action = SocketProtocolService.parseMessage(message);

      navigateWithVideo(action.value);
    }

    return Center(
        child: Column(
      children: [
        Container(
          color: Colors.blueGrey[300],
          child: messages.when(
            loading: () => const Text('Awaiting messages from server...'),
            error: (error, stackTrace) => Text(error.toString()),
            data: (messagesItems) {
              getLastMessage(messagesItems);

              // Display all the messages in a scrollable list view.
              return SocketChat(items: messagesItems);
            },
          ),
        ),
      ],
    ));
  }
}

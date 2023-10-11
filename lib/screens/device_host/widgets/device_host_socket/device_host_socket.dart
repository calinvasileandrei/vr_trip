import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vr_trip/models/socket_protocol_message.dart';
import 'package:vr_trip/services/network_discovery_client/network_discovery_client_provider.dart';
import 'package:vr_trip/services/socket_protocol/socket_protocol_service.dart';
import 'package:vr_trip/shared/socket_chat/socket_chat.dart';
import 'package:vr_trip/utils/logger.dart';

class DeviceHostSocket extends HookConsumerWidget {
  final String serverIp;
  final Function(String) navigateToVrPlayer;

  const DeviceHostSocket(
      {super.key, required this.serverIp, required this.navigateToVrPlayer});

  void getLastMessage(BuildContext context, List<String> messages) async {
    Logger.log('getLastMessage - messages: $messages');
    if (messages.isEmpty) return;

    final lastMessageIndex = messages.length - 1;
    final message = messages[lastMessageIndex];
    SocketAction action = SocketProtocolService.parseMessage(message);

    navigateToVrPlayer(action.value);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(hostMessagesSP(serverIp));
    // If it's in the 'data' state, get the value.
    final List<String> messagesList =
        messages.maybeWhen(data: (value) => value, orElse: () => []);

    useEffect(() {
      Logger.log('useEffect - messagesList: $messagesList');
      if (messagesList.isNotEmpty) {
        // Assuming you have a function named 'handleListChange' that you want to execute:
        getLastMessage(context, messagesList);
      }
      return null;
    }, [messagesList.length]);

    return Center(
        child: Column(
      children: [
        Container(
          color: Colors.blueGrey[300],
          child: messages.when(
            loading: () => const Text('Awaiting messages from server...'),
            error: (error, stackTrace) => Text(error.toString()),
            data: (messagesItems) {
              return SocketChat(items: messagesItems);
            },
          ),
        ),
      ],
    ));
  }
}

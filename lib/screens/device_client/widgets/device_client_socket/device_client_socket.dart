import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vr_trip/models/socket_protocol_message.dart';
import 'package:vr_trip/router/routes.dart';
import 'package:vr_trip/services/network_discovery_client/network_discovery_client_provider.dart';
import 'package:vr_trip/services/socket_protocol/socket_protocol_service.dart';
import 'package:vr_trip/shared/socket_messages/socket_messages.dart';
import 'package:vr_trip/utils/logger.dart';

class DeviceClientSocket extends HookConsumerWidget {
  final String serverIp;

  const DeviceClientSocket({super.key, required this.serverIp});

  void getLastMessage(BuildContext context, List<String> messages) async {
    Logger.log('getLastMessage - messages: $messages');
    if (messages.isEmpty) return;

    SocketAction action = SocketProtocolService.parseMessage(messages.last);

    switch (action.type) {
      case SocketActionTypes.selectVideo:
        Future.delayed(Duration.zero, () {
          context.goNamed(AppRoutes.vrPlayerClient.name, pathParameters: {
            'videoPath': action.value,
            'serverIp': serverIp
          });
        });
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(clientMessagesSP(serverIp));
    final socketConnected = ref.watch(isConnectedSocketClientSP);
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

    renderStartButton() {
      return (ElevatedButton(
          onPressed: () {
            ref.read(socketClientSP(serverIp)).initConnection();
            ref.read(socketClientSP(serverIp)).startConnection();
          },
          child: Text('Connect To Server')));
    }

    useEffect(() {
      // await 1 second and execute code below
      Future.delayed(Duration(seconds: 1), () {
        ref.read(socketClientSP(serverIp)).initConnection();
        ref.read(socketClientSP(serverIp)).startConnection();
      });

      return null;
    }, []);

    return SingleChildScrollView(
        child: Column(
      children: [
        Container(
          color: Colors.blueGrey[300],
          child: messages.when(
            loading: () => const Text('Awaiting messages from server...'),
            error: (error, stackTrace) => Text(error.toString()),
            data: (messagesItems) {
              return SocketMessages(items: messagesItems);
            },
          ),
        ),
        Text('Socket Client connected: $socketConnected'),
        renderStartButton(),
        ElevatedButton(
            onPressed: () {
              ref.read(socketClientSP(serverIp)).stopConnection();
            },
            child: Text('Disconnect'))
      ],
    ));
  }
}

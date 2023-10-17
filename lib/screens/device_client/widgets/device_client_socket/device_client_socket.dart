import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vr_trip/models/socket_protocol_message.dart';
import 'package:vr_trip/providers/socket_client/socket_client_provider.dart';
import 'package:vr_trip/providers/socket_client/types.dart';
import 'package:vr_trip/router/routes.dart';
import 'package:vr_trip/services/socket_protocol/socket_protocol_service.dart';
import 'package:vr_trip/shared/socket_messages/socket_messages.dart';
import 'package:vr_trip/utils/logger.dart';

class DeviceClientSocket extends HookConsumerWidget {
  final String serverIp;
  final String deviceName;

  const DeviceClientSocket({super.key, required this.serverIp, required this.deviceName});

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
    final messages = ref.watch(clientMessagesSP(SocketClientProviderParams(serverIp: serverIp, deviceName: deviceName)));
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
            ref.read(socketClientSP(SocketClientProviderParams(serverIp: serverIp, deviceName: deviceName))).initConnection();
            ref.read(socketClientSP(SocketClientProviderParams(serverIp: serverIp, deviceName: deviceName))).startConnection();
          },
          child: Text('Connect To Server')));
    }


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
              ref.read(socketClientSP(SocketClientProviderParams(serverIp: serverIp, deviceName: deviceName))).stopConnection();
            },
            child: Text('Disconnect'))
      ],
    ));
  }
}

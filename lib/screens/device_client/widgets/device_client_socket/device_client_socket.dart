import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vr_trip/models/socket_protocol_message.dart';
import 'package:vr_trip/providers/socket_client/socket_client_provider.dart';
import 'package:vr_trip/router/routes.dart';
import 'package:vr_trip/services/sockets/socket_protocol/socket_protocol_service.dart';
import 'package:vr_trip/shared/socket_messages/socket_messages.dart';
import 'package:vr_trip/utils/logger.dart';

class DeviceClientSocket extends HookConsumerWidget {
  final String serverIp;
  final String deviceName;

  const DeviceClientSocket(
      {super.key, required this.serverIp, required this.deviceName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final socketClient = ref.watch(socketClientSP);
    final messagesAsyncValue = ref.watch(clientMessagesSP);
    final socketConnected = ref.watch(isConnectedSocketClientSP);

    final List<String> messagesList =
        messagesAsyncValue.maybeWhen(data: (value) => value, orElse: () => []);

    void getLastMessage(List<String> messages) async {
      Logger.log('getLastMessage - messages: $messages');
      if (messages.isEmpty) return;

      SocketAction action = SocketProtocolService.parseMessage(messages.last);

      switch (action.type) {
        case SocketActionTypes.selectVideo:
          Logger.log('getLastMessage - selectVideo');
          if (action.value != 'no_video') {
            Future.delayed(Duration.zero, () {
              context.goNamed(AppRoutes.vrPlayerClient.name, pathParameters: {
                'libraryItemPath': action.value,
              });
            });
          }
          ref.invalidate(clientMessagesSP);
          break;
        default:
          break;
      }
    }

    useEffect(() {
      Logger.log('useEffect - messagesList: $messagesList');
      if (messagesList.isNotEmpty) {
        getLastMessage( messagesList);
      }
      return null;
    }, [messagesList.length]);

    useEffect(() {
      // Initialize the service
      socketClient.initialize(
          host: 'http://${serverIp}',
          port: 3000,
          ref: ref,
          deviceName: deviceName);

      socketClient.initConnection();
      socketClient.startConnection();
      return null;
    }, []);

    Widget getDevelopmentView() {
      return SingleChildScrollView(
          child: Column(
        children: [
          messagesList.isEmpty
              ? Text('No messages')
              : SocketMessages(items: messagesList),
          Text('Socket Client connected: $socketConnected'),
          ElevatedButton(
              onPressed: () {
                ref.read(socketClientSP).initConnection();
                socketClient.startConnection();
              },
              child: Text('Connect To Server')),
        ],
      ));
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          if (socketConnected == true)
            ElevatedButton(
                onPressed: () {
                  ref.read(socketClientSP).stopConnection();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white10,
                  //onPrimary: Colors.black,
                ),
                child: Text('Disconnect'))
        ],
      ),
    ); //getDevelopmentView();
  }
}

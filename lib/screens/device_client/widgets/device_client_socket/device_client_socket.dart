import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vr_trip/models/socket_protocol_message.dart';
import 'package:vr_trip/providers/socket_client/socket_client_provider.dart';
import 'package:vr_trip/providers/socket_client/types.dart';
import 'package:vr_trip/router/routes.dart';
import 'package:vr_trip/services/sockets/socket_protocol/socket_protocol_service.dart';
import 'package:vr_trip/shared/socket_messages/socket_messages.dart';
import 'package:vr_trip/utils/logger.dart';

class DeviceClientSocket extends HookConsumerWidget {
  final String serverIp;
  final String deviceName;

  const DeviceClientSocket(
      {super.key, required this.serverIp, required this.deviceName});

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
    final socketClient = ref.watch(socketClientSP);
    final messagesAsyncValue = ref.watch(clientMessagesSP);
    final socketConnected = ref.watch(isConnectedSocketClientSP);

    useEffect(() {
      messagesAsyncValue.when(data: (messages) {
        Logger.log('useEffect - messagesList: $messages');
        if (messages.isNotEmpty) {
          getLastMessage(context, messages);
        }
      }, loading: () {
        Logger.log('useEffect - loading');
      }, error: (err, stack) {
        Logger.log('useEffect - error: $err');
      });

      return null;
    }, [messagesAsyncValue]);

    useEffect((){
      // Initialize the service
      socketClient.initialize(
          host: 'http://${serverIp}',
          port: 3000,
          ref: ref,
          deviceName: deviceName
      );

      socketClient.initConnection();
      socketClient.startConnection();
        return null;
      }, []);

    return SingleChildScrollView(
        child: Column(
      children: [
        Container(
          color: Colors.blueGrey[300],
          child: messagesAsyncValue.when(
            loading: () => const Text('Awaiting messages from server...'),
            error: (error, stackTrace) => Text(error.toString()),
            data: (messagesItems) {
              return SocketMessages(items: messagesItems);
            },
          ),
        ),
        Text('Socket Client connected: $socketConnected'),
        ElevatedButton(
            onPressed: () {
              ref
                  .read(socketClientSP)
                  .initConnection();
            },
            child: Text('Connect To Server')),
        ElevatedButton(
            onPressed: () {
              ref
                  .read(socketClientSP)
                  .stopConnection();
            },
            child: Text('Disconnect'))
      ],
    ));
  }
}

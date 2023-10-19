import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:vr_trip/models/client_socket_model.dart';

class SocketClients extends HookWidget {
  final List<ClientSocketModel> items;
  final ValueSetter<String>? handleSendMessage;

  const SocketClients({super.key, required this.items, this.handleSendMessage});

  @override
  Widget build(BuildContext context) {
    final textController = useTextEditingController();

    void handleOnPress() {
      handleSendMessage!(textController.text);
    }

    return Container(
      color: Colors.blueGrey[300],
      width: MediaQuery.of(context).size.width,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final connection = items[index];
          return Container(
            child: Row(
              children: [
                Text('Device ${connection.deviceName ?? connection.id}'),
                IconButton(
                    icon: const Icon(Icons.circle),
                    color: connection.lastActionSent ==
                            connection.lastActionReceived
                        ? Colors.green
                        : Colors.red,
                    onPressed: () {})
              ],
            ),
          );
        },
      ),
    );
  }
}

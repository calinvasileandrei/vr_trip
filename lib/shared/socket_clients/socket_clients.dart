import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:vr_trip/models/client_socket_model.dart';
import 'package:vr_trip/shared/ui_kit/my_text/my_text_component.dart';

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
      width: MediaQuery.of(context).size.width,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final connection = items[index];
          return Container(
            // add elevation to the container
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              color: Theme.of(context).colorScheme.background,
              boxShadow: const [
                BoxShadow(
                  color: Colors.white10,
                  offset: Offset(0.0, 1.0), //(x,y)
                  blurRadius: 12.0,
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MyText('Device ${connection.deviceName ?? connection.id}'),
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

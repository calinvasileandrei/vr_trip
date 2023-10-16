import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class SocketClients extends HookWidget {
  final List<String> items;
  final ValueSetter<String>? handleSendMessage;

  const SocketClients({super.key, required this.items, this.handleSendMessage});

  @override
  Widget build(BuildContext context) {
    final textController = useTextEditingController();

    void handleOnPress() {
      handleSendMessage!(textController.text);
    }

    List<Widget> renderSocketInput (){
      if (handleSendMessage == null) {
        return [];
      }
      return [
        TextField(
          controller: textController, // Assign the controller
          decoration: InputDecoration(labelText: 'Enter a message'),
        ),
        IconButton(onPressed: handleOnPress, icon: Icon(Icons.send))
      ];
    }

    return Container(
      color: Colors.blueGrey[300],
      width: MediaQuery.of(context).size.width,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: items.length,
        itemBuilder: (context, index) {
          return Container(
            child: Column(
              children: [
                Text('Device ${items[index]}'),
                ...renderSocketInput()
              ],
            ),
          );
        },
      ),
    );
  }
}

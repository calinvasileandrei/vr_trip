import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class SocketChat extends HookWidget {
  final List<String> items;
  final ValueSetter<String> handleSendMessage;

  const SocketChat({super.key, required this.items,required this.handleSendMessage});

  @override
  Widget build(BuildContext context) {
    final textController = useTextEditingController();

    void handleOnPress() {
      handleSendMessage(textController.text);
    }

    return Container(
      color: Colors.blueGrey[300],
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: items.length,
        itemBuilder: (context, index) {
          return Container(
            child: Column(
              children: [
                Text('Device ${items[index]}'),
                TextField(
                  controller: textController, // Assign the controller
                  decoration: InputDecoration(labelText: 'Enter a message'),
                ),
                IconButton(onPressed: handleOnPress, icon: Icon(Icons.send))
              ],
            ),
          );
        },
      ),
    );
  }
}

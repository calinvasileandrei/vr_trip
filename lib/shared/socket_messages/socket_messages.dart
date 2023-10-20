import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class SocketMessages extends HookWidget {
  final List<String> items;
  final ValueSetter<String>? handleSendMessage;

  const SocketMessages(
      {super.key, required this.items, this.handleSendMessage});

  @override
  Widget build(BuildContext context) {
    final textController = useTextEditingController();

    void handleOnPress() {
      handleSendMessage!(textController.text);
    }

    List<Widget> renderSocketInput() {
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

    return SingleChildScrollView(
      child: Container(
        height: 350,
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        padding: const EdgeInsets.all(12),
        // border radius 12
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        width: MediaQuery.of(context).size.width,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: items.length,
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: [
                  Text('Device ${items[index]}'),
                  ...renderSocketInput()
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

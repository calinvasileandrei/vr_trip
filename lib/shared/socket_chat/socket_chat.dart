import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class SocketChat extends HookWidget {
  final List<String> items;
  const SocketChat({super.key,required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blueGrey[300],
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: items.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(items[index]),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => -1,
            ),
          );
        },
      ),
    );
  }
}

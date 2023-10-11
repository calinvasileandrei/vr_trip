import 'package:flutter/material.dart';
import 'package:vr_trip/models/library_item_model.dart';
import 'package:vr_trip/utils/logger.dart';

class LibraryItem extends StatelessWidget {
  final LibraryItemModel item;
  final Function(LibraryItemModel) onPress;

  const LibraryItem({super.key, required this.item, required this.onPress});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Logger.log('handleItemPress - item: $item');
        onPress(item);
      },
      child: Container(
        width: 50,
        height: 50,
        margin: const EdgeInsets.all(10),
        color: Colors.blue[100],
        child: Center(child: Text(item.name)),
      ),
    );
    ;
  }
}

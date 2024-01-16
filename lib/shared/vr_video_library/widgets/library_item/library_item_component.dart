import 'package:flutter/material.dart';
import 'package:vr_trip/models/library_item_model.dart';
import 'package:vr_trip/utils/logger.dart';

class LibraryItem extends StatelessWidget {
  final LibraryItemModel item;
  final Function(LibraryItemModel) onPress;
  Function(LibraryItemModel)? onLongPress;

  LibraryItem({super.key, required this.item, required this.onPress, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: (){
        Logger.log('handleItemLongPress - item: $item');
        if(onLongPress != null) onLongPress!(item);
      },
      onTap: () {
        Logger.log('handleItemPress - item: $item');
        onPress(item);
      },
      child: Container(
        width: 50,
        height: 50,
        margin: const EdgeInsets.all(10),
        color: Theme.of(context).colorScheme.background,
        child: Center(child: Text(item.name)),
      ),
    );
  }
}

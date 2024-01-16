import 'package:flutter/material.dart';
import 'package:vr_trip/models/download_item_model.dart';
import 'package:vr_trip/utils/logger.dart';

class DownloadItem extends StatelessWidget {
  final DownloadItemModel item;
  final Function(DownloadItemModel) onPress;
  Function(DownloadItemModel)? onLongPress;

  DownloadItem(
      {super.key, required this.item, required this.onPress, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        Logger.log('handleItemLongPress - item: $item');
        if (onLongPress != null) onLongPress!(item);
      },
      onTap: () {
        Logger.log('handleItemPress - item: $item');
        onPress(item);
      },
      child: Container(
        width: 50,
        height: 50,
        margin: const EdgeInsets.all(10),
        color: item.isValidVideo? Colors.lightGreen : Colors.redAccent,
        child: Center(child: Row(
          children: [
            Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.folder,color: Theme.of(context).colorScheme.onSurface)),
            Text(item.name),
          ],
        )),
      ),
    );
  }
}

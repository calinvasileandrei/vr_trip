import 'package:flutter/material.dart';
import 'package:vr_trip/models/library_item_model.dart';
import 'package:vr_trip/screens/vr_player/vr_player_screen.dart';

class LibraryItem extends StatelessWidget {
  final LibraryItemModel item;

  const LibraryItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    void handleNavigateToVr() {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => VrPlayerScreen(videoPath: item.path)));
    }

    return GestureDetector(
      onDoubleTap: handleNavigateToVr,
      child: Container(
        width: 50,
        height: 50,
        margin: const EdgeInsets.all(10),
        color: Colors.blueGrey[100],
        child: Center(child: Text(item.name)),
      ),
    );
    ;
  }
}

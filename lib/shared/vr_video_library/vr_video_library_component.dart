import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vr_trip/models/library_item_model.dart';
import 'package:vr_trip/shared/library_item/library_item_component.dart';

class VrVideoLibrary extends HookWidget {
  const VrVideoLibrary({super.key});

  @override
  Widget build(BuildContext context) {
    final folders = useState<List<LibraryItemModel>>([]);

    Future<List<FileSystemEntity>> getLocalAppStorageFiles() async {
      // Get App Storage Path
      final directory = await getApplicationDocumentsDirectory();
      // Access App Storage
      Directory localAppStorage = Directory(directory.path);
      //List all files in App Storage
      return localAppStorage.listSync();
    }

    handleListFilesInAppStorage() async {
      final localAppStorageList = await getLocalAppStorageFiles();

      for (FileSystemEntity item in localAppStorageList) {
        final shortName = item.path.split('/').last;
        // Save to folders state
        folders.value = [
          ...folders.value,
          LibraryItemModel(name: shortName, path: item.path)
        ];
      }
    }

    useEffect(() {
      handleListFilesInAppStorage();
    }, []);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: folders.value.length,
        itemBuilder: (context, index) {
          return LibraryItem(
            item: folders.value[index],
          );
        },
      ),
    );
  }
}

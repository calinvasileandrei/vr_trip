import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vr_trip/models/library_item_model.dart';
import 'package:vr_trip/shared/library_item/library_item_component.dart';
import 'package:vr_trip/utils/logger.dart';

class VrVideoLibrary extends HookWidget {
  final Function(LibraryItemModel) onItemPress;

  const VrVideoLibrary({super.key, required this.onItemPress});

  @override
  Widget build(BuildContext context) {
    final folders = useState<List<LibraryItemModel>>([]);

    Future<List<FileSystemEntity>> getLocalAppStorageFiles() async {
      try {
        // Get App Storage Path
        final directory = await getApplicationDocumentsDirectory();
        // Access App Storage
        Directory localAppStorage =
            Directory('${directory.path}/VR_Video_Library');

        // If the folder doesn't exist, create it
        if (!await localAppStorage.exists()) {
          await localAppStorage.create();
        }
        //List all files in App Storage
        return localAppStorage.listSync();
      } catch (e) {
        Logger.error('getLocalAppStorageFiles error: $e');
      }
      return [];
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

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: folders.value.length,
          itemBuilder: (context, index) {
            return LibraryItem(
              item: folders.value[index],
              onPress: onItemPress,
            );
          },
        ),
      ),
    );
  }
}

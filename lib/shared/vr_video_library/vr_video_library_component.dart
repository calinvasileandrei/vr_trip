import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:vr_trip/models/library_item_model.dart';
import 'package:vr_trip/shared/library_item/library_item_component.dart';
import 'package:vr_trip/utils/file_utils.dart';
import 'package:vr_trip/utils/logger.dart';

class VrVideoLibrary extends HookWidget {
  final Function(LibraryItemModel) onItemPress;
  Function(LibraryItemModel)? onItemLongPress;

  VrVideoLibrary({super.key, required this.onItemPress, this.onItemLongPress});

  @override
  Widget build(BuildContext context) {
    final folders = useState<List<LibraryItemModel>>([]);
    final directoryWatcher = useRef<StreamSubscription<FileSystemEvent>?>(null);

    handleListFilesInAppStorage() async {
      var fileDirectory = await FileUtils.getLocalAppStorageFolder();
      if (fileDirectory == null) {
        Logger.error('handleListFilesInAppStorage - fileDirectory is null');
        return;
      }

      final localAppStorageList = fileDirectory.listSync();
      List<LibraryItemModel> newFiles = [];
      for (FileSystemEntity item in localAppStorageList) {
        final shortName = item.path.split('/').last;
        // Save to folders state
        newFiles.add(LibraryItemModel(name: shortName, path: item.path));
      }
      folders.value = newFiles;
    }

    useEffect(() {
      handleListFilesInAppStorage();

      (() async {
        Directory? libraryDirectory =
            await FileUtils.getLocalAppStorageFolder();
        if (libraryDirectory != null) {
          directoryWatcher.value = libraryDirectory.watch().listen((event) {
            handleListFilesInAppStorage();
          });
        }
      })();

      return () => directoryWatcher.value?.cancel(); // Cleanup
    }, const []);

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
              onLongPress: (item) {
                if (onItemLongPress != null) {
                  onItemLongPress!(item);
                }
              },
            );
          },
        ),
      ),
    );
  }
}

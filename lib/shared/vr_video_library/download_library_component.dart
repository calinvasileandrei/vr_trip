import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:vr_trip/models/download_item_model.dart';
import 'package:vr_trip/shared/vr_video_library/widgets/download_item/download_item_component.dart';
import 'package:vr_trip/utils/file_utils.dart';
import 'package:vr_trip/utils/logger.dart';

class DownloadLibrary extends HookWidget {
  final Function(DownloadItemModel) onItemPress;
  Function(DownloadItemModel)? onItemLongPress;

  DownloadLibrary({super.key, required this.onItemPress, this.onItemLongPress});

  @override
  Widget build(BuildContext context) {
    final folders = useState<List<DownloadItemModel>>([]);
    final directoryWatcher = useRef<StreamSubscription<FileSystemEvent>?>(null);

    handleListFilesInAppStorage() async {
      var fileDirectory =
          await Directory('/storage/emulated/0/Download/VR_TRIP');
      if (!await fileDirectory.exists()) {
        Logger.error('handleListFilesInAppStorage - fileDirectory is null');
        return;
      }

      final localAppStorageList = fileDirectory.listSync();
      Logger.log(
          'Download Library - localAppStorageList: $localAppStorageList');
      List<DownloadItemModel> newFiles = [];
      for (FileSystemEntity item in localAppStorageList) {
        final shortName = item.path.split('/').last;
        // Save to folders state
        newFiles.add(DownloadItemModel(name: shortName, path: item.path));
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
        color: Theme.of(context).colorScheme.background,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: folders.value.length,
          itemBuilder: (context, index) {
            return DownloadItem(
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

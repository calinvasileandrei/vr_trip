import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:vr_trip/consts/file_consts.dart';
import 'package:vr_trip/models/download_item_model.dart';
import 'package:vr_trip/services/library_reader/library_reader_service.dart';
import 'package:vr_trip/shared/ui_kit/my_button/my_button_component.dart';
import 'package:vr_trip/shared/ui_kit/my_text/my_text_component.dart';
import 'package:vr_trip/shared/vr_video_library/widgets/download_item/download_item_component.dart';
import 'package:vr_trip/utils/file_utils.dart';
import 'package:vr_trip/utils/libraryItem_utils.dart';
import 'package:vr_trip/utils/logger.dart';

class DownloadLibrary extends HookWidget {
  final Function(DownloadItemModel) onItemPress;
  Function(DownloadItemModel)? onItemLongPress;

  DownloadLibrary({super.key, required this.onItemPress, this.onItemLongPress});

  @override
  Widget build(BuildContext context) {
    final folders = useState<List<DownloadItemModel>>([]);
    final directoryWatcher = useRef<StreamSubscription<FileSystemEvent>?>(null);
    final isLoading = useState(false);

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
        newFiles.add(DownloadItemModel(
            name: shortName,
            path: item.path,
            isValidVideo: LibraryItemUtils.isValidLibraryItem(item.path)));
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

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius:
                const BorderRadius.all(Radius.circular(8.0))),
            child: Row(
              children: [
                Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: const Icon(
                      Icons.file_copy_rounded,
                      color: Colors.blue,
                    )),
                MyText(
                  'Downloads/VR_TRIP',
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              margin:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.background,
                  borderRadius:
                  const BorderRadius.all(Radius.circular(8.0))),
              child: ListView.builder(
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
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              MyButton(
                'Importa Downloads/$IMPORT_FOLDER',
                onPressed: () async {
                  isLoading.value = true;
                  //await moveFilesToVRTripFolder();
                  await LibraryReaderService.saveFromDownload();
                  isLoading.value = false;
                },
                isLoading: isLoading.value,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

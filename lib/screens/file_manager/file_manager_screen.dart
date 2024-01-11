import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:vr_trip/models/library_item_model.dart';
import 'package:vr_trip/router/routes.dart';
import 'package:vr_trip/services/library_reader/library_reader_service.dart';
import 'package:vr_trip/shared/ui_kit/my_button/my_button_component.dart';
import 'package:vr_trip/shared/ui_kit/my_text/my_text_component.dart';
import 'package:vr_trip/shared/vr_video_library/download_library_component.dart';
import 'package:vr_trip/shared/vr_video_library/vr_video_library_component.dart';
import 'package:vr_trip/utils/file_utils.dart';
import 'package:vr_trip/utils/logger.dart';

const String IMPORT_FOLDER = 'VR_TRIP';
const String DATA_FOLDER = 'VR_Video_Library';
const String DOWNLOAD_FOLDER = '/storage/emulated/0/Download';

class FileManagerScreen extends HookWidget {
  const FileManagerScreen({super.key});

  Future<void> moveFilesToVRTripFolder() async {
    try {
      // Get the VR_TRIP folder
      final Directory? vrTripFolder =
          await FileUtils.getLocalAppStorageFolder();

      // Get the Download folder for the device
      // Note: This assumes the typical Android path. Adjust if needed for other platforms.
      final Directory downloadDir =
          Directory("$DOWNLOAD_FOLDER/$IMPORT_FOLDER");

      // If the Download directory doesn't exist, exit
      if (!await downloadDir.exists() || vrTripFolder == null) {
        Logger.log("Download directory or VrTrip directory doesn't exist");
        return;
      }

      // List all files in the Download directory
      List<FileSystemEntity> files = downloadDir.listSync();
      // Iterate over all files and move them to the VR_TRIP folder
      for (FileSystemEntity file in files) {
        FileUtils.moveFile(file, vrTripFolder.path);
      }
    } catch (error) {
      Logger.log("Error moving files: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = useState(false);

    handleNavigateToVr(LibraryItemModel item) {
      context.goNamed(AppRoutes.vrPlayerFile.name,
          pathParameters: {'videoPath': item.videoPath});
    }

    handleDeleteItem(LibraryItemModel item) {
      Logger.log('handleDeleteItem - item: $item');
      FileUtils.deleteFile(item.path);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('File Manager'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Container(
        color: Theme.of(context).colorScheme.surface,
        child: Column(
          children: [
            Container(
              child: MyText(
                'Downloads/VR_TRIP:',
                textStyle: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            DownloadLibrary(
              onItemPress: (item) => null,
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              child: MyButton(
                'Importa Download/$IMPORT_FOLDER',
                onPressed: () async {
                  isLoading.value = true;
                  //await moveFilesToVRTripFolder();
                  await LibraryReaderService.saveFromDownload();
                  isLoading.value = false;
                },
                isLoading: isLoading.value,
              ),
            ),
            Container(
              child: MyText(
                'Libreria Interna:',
                textStyle: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            VrVideoLibrary(
              onItemPress: handleNavigateToVr,
              onItemLongPress: handleDeleteItem,
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              child: MyButton(
                'Delete Library',
                onPressed: () async {
                  final Directory? libraryFolder =
                      await FileUtils.getLocalAppStorageFolder();
                  if (libraryFolder != null) {
                    await FileUtils.deleteEverythingInPath(libraryFolder.path);
                  }
                },
                isLoading: isLoading.value,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

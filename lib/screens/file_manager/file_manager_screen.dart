import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:vr_trip/consts/file_consts.dart';
import 'package:vr_trip/models/library_item_model.dart';
import 'package:vr_trip/router/routes.dart';
import 'package:vr_trip/shared/my_snap_view/my_snap_view.dart';
import 'package:vr_trip/shared/vr_video_library/download_library_component.dart';
import 'package:vr_trip/shared/vr_video_library/vr_video_library_component.dart';
import 'package:vr_trip/utils/file_utils.dart';
import 'package:vr_trip/utils/logger.dart';

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
    handleNavigateToVr(LibraryItemModel item) {
      /*context.goNamed(AppRoutes.vrPlayerFile.name, pathParameters: {
        'libraryItemPath': item.path,
      });*/

      Future.delayed(Duration.zero, () {
        context.goNamed(AppRoutes.vrPlayerClient.name, pathParameters: {
          'libraryItemPath': item.path,
          'serverIp': '192.168.1.10'
        });
      });
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
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        body: MySnapView(
          children: [
            DownloadLibrary(
              onItemPress: (item) => null,
            ),
            VrVideoLibrary(
              onItemPress: handleNavigateToVr,
              onItemLongPress: handleDeleteItem,
            )
          ],
        ));
  }
}

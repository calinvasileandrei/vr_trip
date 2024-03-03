import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vr_trip/consts/file_consts.dart';
import 'package:vr_trip/models/library_item_model.dart';
import 'package:vr_trip/providers/google/google_provider.dart';
import 'package:vr_trip/router/routes.dart';
import 'package:vr_trip/shared/keep_alive_page/keep_alive_page.dart';
import 'package:vr_trip/shared/my_snap_view/my_snap_view.dart';
import 'package:vr_trip/shared/vr_video_library/download_library_component.dart';
import 'package:vr_trip/shared/vr_video_library/googledrive_library.dart';
import 'package:vr_trip/shared/vr_video_library/vr_video_library_component.dart';
import 'package:vr_trip/utils/file_utils.dart';
import 'package:vr_trip/utils/logger.dart';

class FileManagerScreen extends HookConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final googleDownloadFolder = ref.watch(googleDownloadFolderSP);

    handleNavigateToVr(LibraryItemModel item) {
      Future.delayed(Duration.zero, () {
        context.goNamed(AppRoutes.vrPlayerFile.name,
            pathParameters: {'libraryItemPath': item.path});
      });
    }

    handleDeleteItem(LibraryItemModel item) {
      Logger.log('handleDeleteItem - item: $item');
      FileUtils.deleteEverythingInPath(item.path);
    }

    return WillPopScope(
      onWillPop: () async {
        ref.invalidate(authGoogleSP);
        ref.invalidate(googleSignInSP);
        ref.invalidate(googleAccountSP);
        ref.invalidate(googleDriveFoldersSP);
        return true;
      },
      child: Scaffold(
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
              ),
              KeepAlivePage(
                  keepPageAlive: googleDownloadFolder.isNotEmpty,
                  child: const GoogleDriveLibrary()),
            ],
          )),
    );
  }
}

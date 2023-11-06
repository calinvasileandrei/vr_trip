import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:vr_trip/models/library_item_model.dart';
import 'package:vr_trip/router/routes.dart';
import 'package:vr_trip/shared/ui_kit/my_button/my_button_component.dart';
import 'package:vr_trip/shared/ui_kit/my_text/my_text_component.dart';
import 'package:vr_trip/shared/vr_video_library/vr_video_library_component.dart';
import 'package:vr_trip/utils/logger.dart';

class FileManagerScreen extends HookWidget {
  const FileManagerScreen({super.key});

  Future<Directory?> getLocalAppStorageFolder() async {
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
      return localAppStorage;
    } catch (e) {
      Logger.error('getLocalAppStorageFiles error: $e');
    }
    return null;
  }

  Future<void> moveFilesToVRTripFolder() async {
    try {
      // Get the VR_TRIP folder
      final Directory? vrTripFolder = await getLocalAppStorageFolder();

      if (vrTripFolder == null) {
        return;
      }

      // Get the Download folder for the device
      // Note: This assumes the typical Android path. Adjust if needed for other platforms.
      final Directory downloadDir = Directory("/storage/emulated/0/Download");

      // If the Download directory doesn't exist, exit
      if (!await downloadDir.exists()) {
        Logger.log("Download directory doesn't exist");
        return;
      }

      // List all files in the Download directory
      List<FileSystemEntity> files = downloadDir.listSync();

      // Iterate over all files and move them to the VR_TRIP folder
      for (FileSystemEntity file in files) {
        try {
          if (file is File) {
            final String basename = p.basename(file.path);
            final File newLocation = File('${vrTripFolder.path}/$basename');
            await file.copy(newLocation.path);
            Logger.log('File moved: ${file.path}');
            await file.delete();
          }
        } catch (e) {
          Logger.log("Error moving file: $e");
        }
      }
    } catch (error) {
      Logger.log("Error moving files: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    handleNavigateToVr(LibraryItemModel item) {
      context.goNamed(AppRoutes.vrPlayerFile.name,
          pathParameters: {'videoPath': item.path});
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
              margin: const EdgeInsets.symmetric(vertical: 20),
              child: MyButton('Importa file da Download/VR_TRIP', onPressed: moveFilesToVRTripFolder),
            ),
            Container(
              child: MyText(
                'Percorsi importati:',
                textStyle: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            VrVideoLibrary(onItemPress: handleNavigateToVr),

          ],
        ),
      ),
    );
  }
}

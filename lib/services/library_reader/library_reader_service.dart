import 'dart:convert';
import 'dart:io';

import 'package:vr_trip/consts/file_consts.dart';
import 'package:vr_trip/utils/file_utils.dart';

import '../../models/library_item_model.dart';
import '../../utils/logger.dart';

class LibraryReaderService {

  static Future<void> saveFromDownload() async {
    try {
      // Get the VR_TRIP folder
      final Directory? libraryFolder =
          await FileUtils.getLocalAppStorageFolder();

      // Get the Download folder for the device
      // Note: This assumes the typical Android path. Adjust if needed for other platforms.
      final Directory downloadDir =
          Directory("$DOWNLOAD_FOLDER/$IMPORT_FOLDER");

      // If the Download directory doesn't exist, exit
      if (!await downloadDir.exists() || libraryFolder == null) {
        Logger.log("Download directory or VrTrip directory doesn't exist");
        return;
      }

      // List all files in the Download directory
      List<FileSystemEntity> files = downloadDir.listSync();
      // Iterate over all files and move them to the VR_TRIP library folder
      for (FileSystemEntity file in files) {
        if (await FileSystemEntity.isDirectory(file.path)) {
          // Check if the directory contains both video.mp4 and transcript.json
          var directory = await getDirectoryFromFilePath(file.path);

          if (directory != null) {
            await FileUtils.copyLibraryItemDirectory(
                directory.path, libraryFolder.path);
            Logger.log(
                "Moved directory ${directory.path} to ${libraryFolder.path}");
          } else {
            Logger.log(
                "Directory ${file.path} does not contain the required files.");
          }
        }
      }
    } catch (error) {
      Logger.log("Error moving files: $error");
    }
  }

  static Future<List<LibraryItemModel>> loadLibrary() async {
    // open directory
    var libraryFolder = await FileUtils.getLocalAppStorageFolder();

    if (libraryFolder == null) {
      Logger.error('handleListFilesInAppStorage - fileDirectory is null');
      throw Exception('Library folder not found');
    }

    Logger.log('Loading video library');

    final localAppStorageList = libraryFolder.listSync();
    List<LibraryItemModel> newFiles = [];

    for (FileSystemEntity item in localAppStorageList) {
      var directory = await getDirectoryFromFilePath(item.path);
      Logger.log('Checking directory ${item.path}');
      if (directory == null) {
        Logger.error('Directory ${item.path} is not valid');
        continue;
      }
      final directoryName = directory.path.split('/').last;
      var transcriptFile =
          await File('${directory.path}/transcript.json').readAsString();
      final TranscriptObject transcriptObject = TranscriptObject.fromJson(json.decode(transcriptFile));


      // Save to folders state
      newFiles.add(LibraryItemModel(name: directoryName, path: directory.path, videoPath: '${directory.path}/video.mp4', transcriptObject: transcriptObject));
      Logger.log('Added directory ${directory.path} to library');
    }

    return newFiles;
  }

  static Future<Directory?> getDirectoryFromFilePath(String filePath) async {
    if (await FileSystemEntity.isDirectory(filePath)) {
      // Check if the directory contains both video.mp4 and transcript.json
      Directory directory = Directory(filePath);
      bool containsVideo = await File('${directory.path}/video.mp4').exists();
      bool containsTranscript =
          await File('${directory.path}/transcript.json').exists();

      if (containsVideo && containsTranscript) {
        return directory;
      }
      Logger.log(
          "Directory ${directory.path} does not contain the required files.");
    }
    return null;
  }

  static Future<bool> integrityItemCheck(String itemPath) async {
    var videoFilePath = await FileUtils.fileExists('$itemPath/video.mp4');
    var transcriptFilePath =
        await FileUtils.fileExists('$itemPath/transcript.json');

    if (videoFilePath == false || transcriptFilePath == false) {
      return false;
    }
    return true;
  }
}

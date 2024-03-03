import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:vr_trip/consts/file_consts.dart';
import 'package:vr_trip/utils/logger.dart';

const String prefix = 'FileUtils';

class FileUtils {
  static Future<Directory?> getDownloadFolder() async {
    try {
      // Get App Storage Path
      final directory = await getLocalAppStorageFolderPath();
      // Access App Storage
      Directory downloadFolder = Directory(DOWNLOAD_FOLDER);

      return downloadFolder;
    } catch (e) {
      Logger.error('getDownloadFolder error: $e');
    }
    return null;
  }

  static Future<String> getLocalAppStorageFolderPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<Directory?> getLocalAppStorageFolder() async {
    try {
      // Get App Storage Path
      final directory = await getLocalAppStorageFolderPath();
      // Access App Storage
      Directory localAppStorage = Directory('${directory}/$DATA_FOLDER');

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

  static void deleteFile(String filePath) async {
    try {
      final file = File(filePath);

      if (await file.exists()) {
        await file.delete();
        Logger.log('$prefix File deleted successfully');
      } else {
        Logger.warn('$prefix File does not exist');
      }
    } catch (e) {
      Logger.error('$prefix Error deleting file: $e');
    }
  }

  static Future<void> moveFile(
      FileSystemEntity fromFilePath, String toFolderPath) async {
    try {
      if (fromFilePath is File) {
        final String basename = p.basename(fromFilePath.path);
        final String newLocationPath = '$toFolderPath/$basename';

        if (await fileExists(newLocationPath)) {
          Logger.log('File already exists in new location');
          return;
        }

        final File newLocation = File(newLocationPath);
        await fromFilePath.copy(newLocation.path);
        Logger.log('File copied to new path: $toFolderPath');
        deleteFile(fromFilePath.path);
        Logger.log('File moved : ${basename}');
      }
    } catch (e) {
      Logger.error("Error moving file: $e");
    }
  }

  static Future<bool> copyLibraryItemDirectory(
      String sourcePath, String finalPath) async {
    final directoryName = sourcePath.split('/').last;

    Directory newDirectory = Directory('$finalPath/$directoryName');
    var videoFileExists = await fileExists('$sourcePath/video.mp4');
    var transcriptFileExists = await fileExists('$sourcePath/transcript.json');

    if (!newDirectory.existsSync() && videoFileExists && transcriptFileExists) {
      await newDirectory.create(recursive: true);
      Logger.log('Created directory $finalPath');

      File videoFile = File('$sourcePath/video.mp4');
      await videoFile.copy('${newDirectory.path}/video.mp4');
      Logger.log('Copied video file');

      File transcriptFile = File('$sourcePath/transcript.json');
      await transcriptFile.copy('${newDirectory.path}/transcript.json');
      Logger.log('Copied transcript file');

      Logger.log('Library - result: ${newDirectory.listSync()}');

      return true;
    }
    Logger.error(
        'copyLibraryItemDirectory - video exists ($videoFileExists) or transcript exists($transcriptFileExists) file or directory already exists');
    return false;
  }

  static Future<void> deleteEverythingInPath(String targetPath) async {
    // Check if the target path exists
    var targetDir = Directory(targetPath);
    if (await targetDir.exists()) {
      // Get a list of all files and subdirectories in the target directory
      List<FileSystemEntity> entities = Directory(targetPath).listSync();

      // Delete each file/directory
      for (var entity in entities) {
        Logger.log('Deleting entity ${entity.path}');
        if (entity is File) {
          // If it's a file, delete it
          await entity.delete();
          Logger.log('Deleted file ${entity.path.split('/').last}');
        } else if (entity is Directory) {
          // If it's a directory, recursively delete it
          Logger.log('Deleting directory ${entity.path}');
          entity.deleteSync(recursive: true);
        }
      }
      Logger.log('Deleted everything in $targetPath completed');
      targetDir.deleteSync();
      Logger.log('Deleted directory $targetPath completed');
    } else {
      Logger.error('Target path does not exist');
    }

    Logger.log('Delete Target - result: ${Directory(targetPath).listSync()}');
  }

  static Future<bool> fileExists(String filePath) async {
    final file = File(filePath);
    return await file.exists();
  }

  static void listDirectoryContents(String path) {
    Directory directory = Directory(path);
    List contents = directory.listSync();
    for (var content in contents) {
      if (content is File) {
        Logger.log('File: ${content.path}');
      } else if (content is Directory) {
        Logger.log('Directory: ${content.path}');
        listDirectoryContents(content.path);
      }
    }
  }
}

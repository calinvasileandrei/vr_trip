import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:vr_trip/utils/logger.dart';
import 'package:path/path.dart' as p;

const String prefix = 'FileUtils';
const String DATA_FOLDER = 'VR_Video_Library';
const String DOWNLOAD_FOLDER = '/storage/emulated/0/Download';

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

  static moveFile(FileSystemEntity fromFilePath, String toFolderPath) async {
    try {
      if (fromFilePath is File) {
        final String basename = p.basename(fromFilePath.path);
        final String newLocationPath = '$toFolderPath/$basename';

        if(await fileExists(newLocationPath)){
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

  static Future<bool> fileExists(String filePath) async {
    final file = File(filePath);
    return await file.exists();
  }
}


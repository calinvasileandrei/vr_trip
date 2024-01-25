import 'dart:io';
import 'dart:typed_data';

import 'package:googleapis/drive/v3.dart' as drive;
import 'package:vr_trip/services/google_auth_client/google_auth_client.dart';
import 'package:vr_trip/utils/logger.dart';

const prefix = '[GoogleDriveService]';

class GoogleDriveService {
  static Future<void> downloadFile(drive.File file,
      GoogleAuthClient authenticateClient, String filepath) async {
    final driveApi = drive.DriveApi(authenticateClient);
    final response = await driveApi.files
        .get(file.id!, downloadOptions: drive.DownloadOptions.fullMedia);
    if (response is! drive.Media) throw Exception("invalid response");

    final stream = response.stream;
    // Specify the local path where you want to save the file
    final localPath = '$filepath/${file.name}';

    // Write the file content to the local path
    final fileSave = File(localPath);
    final IOSink sink = fileSave.openWrite();
    await sink.addStream(stream.cast<Uint8List>());
    await sink.close();
    // Notify the user or perform any other actions if needed
    Logger.log('$prefix File downloaded to: $localPath');
  }

  static Future<void> downloadFolder(
      drive.File folder,
      GoogleAuthClient authenticateClient,
      drive.DriveApi driveApi,
      String folderPath) async {
    // Get the list of files inside the folder
    final folderFiles =
        await driveApi.files.list(q: "'${folder.id}' in parents");

    if (folderFiles.files == null || folderFiles.files!.isEmpty) {
      Logger.error('$prefix Error downloading folder: ${folder.name}');
      throw Exception('No files found.');
    }

    // Download each file inside the folder
    for (final file in folderFiles.files!) {
      await downloadFile(file, authenticateClient, folderPath);
    }
    // Notify the user or perform any other actions if needed
    Logger.log('Folder downloaded: ${folder.name}');
  }
}

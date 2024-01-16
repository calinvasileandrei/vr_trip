
import 'dart:convert';
import 'dart:io';

import 'package:vr_trip/models/library_item_model.dart';

class LibraryItemUtils {

  static Future<LibraryItemModel?> fetchLibraryItem(String folderPath) async {
    final Directory folder = Directory(folderPath);

    // Check if the directory exists
    if (!await folder.exists()) {
      return null;
    }

    // Read video file
    final File videoFile = File('${folder.path}/video.mp4');
    if (!await videoFile.exists()) {
      return null;
    }

    // Read transcript file
    final File transcriptFile = File('${folder.path}/transcript.json');
    if (!await transcriptFile.exists()) {
      return null;
    }

    try {
      // Read and parse JSON from transcript file
      final String transcriptJson = await transcriptFile.readAsString();
      final TranscriptObject transcriptObject = TranscriptObject.fromJson(json.decode(transcriptJson));

      // Create LibraryItemModel
      final LibraryItemModel libraryItem = LibraryItemModel(
        name: folder.uri.pathSegments.last,
        path: folder.path,
        videoPath: videoFile.path,
        transcriptObject: transcriptObject,
      );

      return libraryItem;
    } catch (e) {
      // Handle any errors while reading or parsing files
      print('Error: $e');
      return null;
    }
  }
}

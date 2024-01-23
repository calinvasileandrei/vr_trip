
import 'dart:convert';
import 'dart:io';

import 'package:vr_trip/models/library_item_model.dart';
import 'package:vr_trip/utils/logger.dart';

const prefix = '[library_item_utils]';
class LibraryItemUtils {


  static bool isValidLibraryItem(String folderPath) {
    final Directory folder = Directory(folderPath);

    // Check if the directory exists
    if (!folder.existsSync()) {
      Logger.log('$prefix Folder does not exist');
      return false;
    }

    // Read video file
    final File videoFile = File('${folder.path}/video.mp4');
    if (!videoFile.existsSync()) {
      Logger.log('$prefix Video file does not exist');
      return false;
    }

    // Read transcript file
    final File transcriptFile = File('${folder.path}/transcript.json');
    if (!transcriptFile.existsSync()) {
      Logger.log('$prefix Transcript file does not exist');
      return false;
    }

    try {
      // Read and parse JSON from transcript file
      final String transcriptJson = transcriptFile.readAsStringSync();
      final TranscriptObject transcriptObject = TranscriptObject.fromJson(json.decode(transcriptJson));
      Logger.log('$prefix Transcript object: $transcriptObject');
      // Create LibraryItemModel
      final LibraryItemModel libraryItem = LibraryItemModel(
        name: folder.uri.pathSegments.last,
        path: folder.path,
        videoPath: videoFile.path,
        transcriptObject: transcriptObject,
      );

      return true;
    } catch (e) {
      // Handle any errors while reading or parsing files
      Logger.error('$prefix Error: $e');
      return false;
    }
  }

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

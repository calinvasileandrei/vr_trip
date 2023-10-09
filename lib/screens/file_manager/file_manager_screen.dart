import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vr_trip/shared/vr_video_library/vr_video_library_component.dart';
import 'package:vr_trip/utils/logger.dart';

class FileManagerScreen extends HookWidget {
  const FileManagerScreen({super.key});

  Future<void> moveFile(String sourceFilePath, String newPath) async {
    File sourceFile = File(sourceFilePath);
    try {
      var file = File(sourceFilePath);
      if (await file.exists()) {
        final copyFile = file.copySync(newPath);
        if (file.existsSync()) {
          file.delete();
          Logger.log('File moved to: ${copyFile.path}');
        }
      } else {
        Logger.log('Cannot delete, File not exists');
      }
    } on FileSystemException catch (e) {
      Logger.error('moveFile error: $e');
      // if rename fails, copy the source file and then delete it
    }
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  handleMoveFile() async {
    final internalAppPath = await _localPath;

    // Get all files inside Download folder
    Directory dirDownload = Directory('/storage/emulated/0/Download');
    var downloadsFile = dirDownload.listSync().where((e) => e is File);
    Logger.log('downloadsFile: $downloadsFile');

    // Iterate on each file and move to internal app folder
    downloadsFile.forEach((element) {
      Logger.log('element: $element');
      final newFileName = element.path.split('/').last;
      final newFilePath = '$internalAppPath/$newFileName';
      moveFile(element.path, newFilePath);
    });

    Logger.log('Handle Move File completed');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File Manager'),
      ),
      body: Center(
          child: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              //socket.emit('message', 'Hello from Socket Screen');
              handleMoveFile();
            },
            child: Text('Move File'),
          ),
          const VrVideoLibrary(),
        ],
      )),
    );
  }
}

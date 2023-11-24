import 'package:vr_trip/utils/file_utils.dart';

class LibraryReaderService{

  void loadLibraryItem(String videoFolderName) async{
    // Check folder, video and transcript integrity
    // If folder is not exist, throw error
    // If video is not exist, throw error
    // If transcript is not exist, throw error

    // open directory
    var libraryFolder = await FileUtils.getLocalAppStorageFolder();

    var videoFilePath = await FileUtils.fileExists('${libraryFolder!.path}/$videoFolderName/video.mp4');
    var transcriptFilePath = await FileUtils.fileExists('${libraryFolder.path}/$videoFolderName/transcript.json');

    if(videoFilePath == false || transcriptFilePath == false){
      throw Exception('Video not found');
    }



  }


}

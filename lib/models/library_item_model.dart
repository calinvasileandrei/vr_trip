class LibraryItemModel {
  final name;
  final path;
  final videoPath;
  final transcriptObject;

  LibraryItemModel({required this.name, required this.path, required this.videoPath, required this.transcriptObject});

  LibraryItemModel.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        path = json['path'],
        videoPath = json['videoPath'],
        transcriptObject = json['transcriptObject'];

  Map<String, dynamic> toJson() => {
    'name': name,
    'path': path,
    'videoPath': videoPath,
    'transcriptObject': transcriptObject,
  };

  String toString() {
    return '{from: $name, path: $path, videoPath: $videoPath, transcriptObject: $transcriptObject}';
  }
}


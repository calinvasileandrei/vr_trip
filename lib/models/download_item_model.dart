class DownloadItemModel {
  final name;
  final path;
  final isValidVideo;

  DownloadItemModel({required this.name, required this.path,required this.isValidVideo});

  DownloadItemModel.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        path = json['path'],
        isValidVideo = json['isValidVideo'];

  Map<String, dynamic> toJson() => {
    'name': name,
    'path': path,
    'isValidVideo': isValidVideo,
  };

  String toString() {
    return '{from: $name, path: $path}, isValidVideo: $isValidVideo';
  }
}


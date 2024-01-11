class DownloadItemModel {
  final name;
  final path;

  DownloadItemModel({required this.name, required this.path});

  DownloadItemModel.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        path = json['path'];

  Map<String, dynamic> toJson() => {
    'name': name,
    'path': path,
  };

  String toString() {
    return '{from: $name, path: $path}';
  }
}


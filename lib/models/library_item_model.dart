class LibraryItemModel {
  final name;
  final path;

  LibraryItemModel({required this.name, required this.path});

  LibraryItemModel.fromJson(Map<String, dynamic> json)
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


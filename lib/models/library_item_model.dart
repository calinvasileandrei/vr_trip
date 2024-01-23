class LibraryItemModel {
  final String name;
  final String path;
  final String videoPath;
  final TranscriptObject transcriptObject;

  LibraryItemModel({
    required this.name,
    required this.path,
    required this.videoPath,
    required this.transcriptObject,
  });

  factory LibraryItemModel.fromJson(Map<String, dynamic> json) {
    return LibraryItemModel(
      name: json['name'] ?? '',
      path: json['path'] ?? '',
      videoPath: json['videoPath'] ?? '',
      transcriptObject:
          TranscriptObject.fromJson(json['transcriptObject'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'path': path,
      'videoPath': videoPath,
      'transcriptObject': transcriptObject.toJson(),
    };
  }
}

class TranscriptObject {
  final String nomeVideo;
  final List<TimelineItem> timeline;

  TranscriptObject({
    required this.nomeVideo,
    required this.timeline,
  });

  factory TranscriptObject.fromJson(Map<String, dynamic> json) {
    return TranscriptObject(
      nomeVideo: json['nomeVideo'] ?? '',
      timeline: (json['timeline'] as List<dynamic>?)
              ?.map((item) => TimelineItem.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nomeVideo': nomeVideo,
      'timeline': timeline.map((item) => item.toJson()).toList(),
    };
  }
}

class TimelineItem {
  final String nomeClip;
  final String start;
  final String end;

  TimelineItem({
    required this.nomeClip,
    required this.start,
    required this.end,
  });

  factory TimelineItem.fromJson(Map<String, dynamic> json) {
    return TimelineItem(
      nomeClip: json['nomeClip'] ?? '',
      start: json['start'] ?? '',
      end: json['end'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nomeClip': nomeClip,
      'start': start,
      'end': end,
    };
  }

  @override
  String toString() {
    return 'TimelineItem{nomeClip: $nomeClip, start: $start, end: $end}';
  }
}

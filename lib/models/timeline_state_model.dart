import 'package:vr_trip/models/library_item_model.dart';
import 'package:vr_trip/utils/date_utils.dart';
import 'package:vr_trip/utils/vr_player_utils.dart';

enum TimelinePosition {
  start,
  end;

  String toJson() => name;
  static TimelinePosition fromJson(String json) => values.byName(json);
}

class TimelineStateModel {
  final int _start;
  final int _end;
  final TimelinePosition? _currentPosition;

  TimelineStateModel({required start, required end, currentPosition})
      : _start = start,
        _end = end,
        _currentPosition = currentPosition;

  String getCurrentPositionString() {
    return millisecondsToDateTime(
        _currentPosition == TimelinePosition.start ? _start : _end);
  }

  int getSeekPositionInt() {
    return _currentPosition == TimelinePosition.start ? _start : _end;
  }

  double getSeekPositionDouble() {
    return getSeekPositionInt().toDouble();
  }

  int get getStart => _start;

  int get getEnd => _end;

  double get getStartDouble => _start.toDouble();

  double get getEndDouble => _end.toDouble();

  TimelinePosition? get getCurrentPosition => _currentPosition;

  // factory
  TimelineStateModel.fromItem(
      TimelineItem item, TimelinePosition? currentPosition)
      : _start = VrPlayerUtils.timeStringToMilliseconds(item.start),
        _end = VrPlayerUtils.timeStringToMilliseconds(item.end),
        _currentPosition = currentPosition;

  Map<String, dynamic> toJson() => {
        'start': _start,
        'end': _end,
        'currentPosition': _currentPosition?.toJson()
      };

  factory TimelineStateModel.fromJson(Map<String, dynamic> json) =>
      TimelineStateModel(
          start: json['start'],
          end: json['end'],
          currentPosition: TimelinePosition.fromJson(json['currentPosition'])
      );

  @override
  String toString() {
    return 'TimelineStateModel{_start: $_start, _end: $_end, currentPosition: ${getCurrentPositionString()}}';
  }
}

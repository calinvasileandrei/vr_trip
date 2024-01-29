import 'package:vr_trip/models/library_item_model.dart';
import 'package:vr_trip/utils/date_utils.dart';
import 'package:vr_trip/utils/vr_player_utils.dart';

enum TimelinePosition { start, end }

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

  get getStart => _start;

  get getEnd => _end;

  get getStartDouble => _start.toDouble();

  get getEndDouble => _end.toDouble();

  get getCurrentPosition => _currentPosition;

  // factory
  TimelineStateModel.fromItem(
      TimelineItem item, TimelinePosition? currentPosition)
      : _start = VrPlayerUtils.timeStringToMilliseconds(item.start),
        _end = VrPlayerUtils.timeStringToMilliseconds(item.end),
        _currentPosition = currentPosition;

  Map<String, dynamic> toJson() => {
        'start': _start,
        'end': _end,
        'currentPosition': _currentPosition?.toString()
      };

  factory TimelineStateModel.fromJson(Map<String, dynamic> json) =>
      TimelineStateModel(
          start: json['start'],
          end: json['end'],
          currentPosition: json['currentPosition']);

  @override
  String toString() {
    return 'TimelineStateModel{_start: $_start, _end: $_end, currentPosition: ${getCurrentPositionString()}}';
  }
}

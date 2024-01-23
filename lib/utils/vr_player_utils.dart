
import 'package:vr_trip/models/library_item_model.dart';
import 'package:vr_trip/models/timeline_state_model.dart';
import 'package:vr_trip/utils/date_utils.dart';
import 'package:vr_trip/utils/logger.dart';

class VrPlayerUtils {

  static int timeStringToMilliseconds(String timeString) {
    List<String> timeComponents = timeString.split(':');

    if (timeComponents.length != 3) {
      throw FormatException('Invalid time string format');
    }

    int hours = int.parse(timeComponents[0]);
    int minutes = int.parse(timeComponents[1]);
    int seconds = int.parse(timeComponents[2]);

    return (hours * 3600 + minutes * 60 + seconds) * 1000;
  }


  static bool isTimeLineItemInRange(int millis, TimelineItem timelineItem) {
    var start = timeStringToMilliseconds(timelineItem.start);
    var end = timeStringToMilliseconds(timelineItem.end);

    return millis >= start && millis <= end;
  }

  static TimelineItem computeTimeLineItem(int millis,List<TimelineItem> timeline){
    var durationText = millisecondsToDateTime(millis);
    var position = timeStringToMilliseconds(durationText);

    var timelineItem = timeline.firstWhere((element) => isTimeLineItemInRange(position, element),orElse: ()=> timeline.first);

    return timelineItem;
  }


  static TimelineStateModel getTimelineTimingsForState(TimelineItem timelineItem, TimelinePosition position){

    int startSeekPosition =
        VrPlayerUtils.timeStringToMilliseconds(timelineItem.start) +
            1000;
    int endSeekPosition =
        VrPlayerUtils.timeStringToMilliseconds(timelineItem.end) +
            1000;

    return TimelineStateModel(start: startSeekPosition, end: endSeekPosition,currentPosition: position);
  }

  static TimelineStateModel getPreviousTimelineItem(TimelineItem item,List<TimelineItem> timeline){
    var index = timeline.indexWhere((element) => element.nomeClip == item.nomeClip);
    Logger.log('getPreviousTimelineItem : timeline: $timeline \n current index: $index, previous index: ${index-1}, item: ${timeline[index-1]}');

    if(index == 0) return TimelineStateModel.fromItem(item, TimelinePosition.start);

    return TimelineStateModel.fromItem(timeline[index-1], TimelinePosition.start);
  }

  static TimelineStateModel getNextTimelineItem(TimelineItem item,List<TimelineItem> timeline){
    var index = timeline.indexWhere((element) => element.nomeClip == item.nomeClip);
    Logger.log('getPreviousTimelineItem : timeline: $timeline \n current index: $index, next index: ${index+1}, item: ${timeline[index+1]}');
    if(index == timeline.length-1) return TimelineStateModel.fromItem(item, TimelinePosition.end);

    return TimelineStateModel.fromItem(timeline[index+1], TimelinePosition.start);
  }
}

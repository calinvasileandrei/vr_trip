
import 'package:vr_trip/models/library_item_model.dart';
import 'package:vr_trip/utils/date_utils.dart';

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
}

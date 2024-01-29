import 'package:vr_trip/models/timeline_state_model.dart';

enum VideoPreviewEvent { play, pause, forward, backward, none }

class VideoAction {
  final VideoPreviewEvent type;
  final TimelineStateModel? state;

  VideoAction({required this.type, this.state});

  @override
  String toString() {
    return 'VideoAction{type: $type, state: $state}';
  }
}

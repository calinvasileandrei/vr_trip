import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vr_trip/models/library_item_model.dart';

import 'types.dart';

final videoPreviewEventSP = StateProvider<VideoAction?>((ref) => null);

final deviceManagerProvider =
    StateNotifierProvider<DeviceManagerNotifier, DeviceManagerState>(
  (ref) => DeviceManagerNotifier(),
);

class DeviceManagerNotifier extends StateNotifier<DeviceManagerState> {
  DeviceManagerNotifier() : super(DeviceManagerState());

  void setSelectedLibraryItem(LibraryItemModel? libraryItem) {
    state = state.copyWith(selectedLibraryItem: libraryItem);
  }

  void setVideoPreviewEvent(VideoAction? videoAction) {
    state = state.copyWith(videoPreviewEvent: videoAction);
  }

  void setCurrentTimeLineItem(TimelineItem? timelineItem) {
    state = state.copyWith(currentTimeLineItem: timelineItem);
  }
}

class DeviceManagerState {
  final LibraryItemModel? selectedLibraryItem;
  final VideoAction? videoPreviewEvent;
  final TimelineItem? currentTimeLineItem;

  DeviceManagerState({
    this.selectedLibraryItem,
    this.videoPreviewEvent,
    this.currentTimeLineItem,
  });

  DeviceManagerState copyWith({
    LibraryItemModel? selectedLibraryItem,
    VideoAction? videoPreviewEvent,
    TimelineItem? currentTimeLineItem,
  }) {
    return DeviceManagerState(
      selectedLibraryItem: selectedLibraryItem ?? this.selectedLibraryItem,
      videoPreviewEvent: videoPreviewEvent ?? this.videoPreviewEvent,
      currentTimeLineItem: currentTimeLineItem ?? this.currentTimeLineItem,
    );
  }
}

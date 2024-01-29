import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vr_trip/models/library_item_model.dart';

final myVrPlayerProvider =
    StateNotifierProvider<MyVrPlayerNotifier, MyVrPlayerState>(
  (ref) => MyVrPlayerNotifier(),
);

class MyVrPlayerNotifier extends StateNotifier<MyVrPlayerState> {
  MyVrPlayerNotifier() : super(MyVrPlayerState());

  void setVideoLoading(bool isLoading) {
    state = state.copyWith(isVideoLoading: isLoading);
  }

  void setVideoReady(bool isReady) {
    state = state.copyWith(isVideoReady: isReady);
  }

  void setVideoFinished(bool isFinished) {
    state = state.copyWith(isVideoFinished: isFinished);
  }

  void setPlayingStatus(bool isPlaying) {
    state = state.copyWith(isPlaying: isPlaying);
  }

  void setDuration(String duration, int intDuration) {
    state = state.copyWith(duration: duration, intDuration: intDuration);
  }

  void setSeekPosition(double position) {
    state = state.copyWith(seekPosition: position);
  }

  void setCurrentPosition(String position) {
    state = state.copyWith(currentPosition: position);
  }

  void toggleVRMode(bool isVR) {
    state = state.copyWith(isVR: isVR);
  }

  void setLibraryItem(LibraryItemModel? libraryItem) {
    state = state.copyWith(libraryItem: libraryItem);
  }
}

class MyVrPlayerState {
  final bool isVideoLoading;
  final bool isVideoReady;
  final bool isVideoFinished;
  final bool isPlaying;
  final String? duration;
  final int? intDuration;
  final double seekPosition;
  final String? currentPosition;
  final bool isVR;
  final LibraryItemModel? libraryItem;

  MyVrPlayerState({
    this.isVideoLoading = false,
    this.isVideoReady = false,
    this.isVideoFinished = false,
    this.isPlaying = false,
    this.duration,
    this.intDuration,
    this.seekPosition = 0,
    this.currentPosition,
    this.isVR = false,
    this.libraryItem,
  });

  MyVrPlayerState copyWith({
    bool? isVideoLoading,
    bool? isVideoReady,
    bool? isVideoFinished,
    bool? isPlaying,
    String? duration,
    int? intDuration,
    double? seekPosition,
    String? currentPosition,
    bool? isVR,
    LibraryItemModel? libraryItem,
  }) {
    return MyVrPlayerState(
      isVideoLoading: isVideoLoading ?? this.isVideoLoading,
      isVideoReady: isVideoReady ?? this.isVideoReady,
      isVideoFinished: isVideoFinished ?? this.isVideoFinished,
      isPlaying: isPlaying ?? this.isPlaying,
      duration: duration ?? this.duration,
      intDuration: intDuration ?? this.intDuration,
      seekPosition: seekPosition ?? this.seekPosition,
      currentPosition: currentPosition ?? this.currentPosition,
      isVR: isVR ?? this.isVR,
      libraryItem: libraryItem ?? this.libraryItem,
    );
  }
}

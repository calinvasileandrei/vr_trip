import 'package:hooks_riverpod/hooks_riverpod.dart';

final vrPlayerClientProvider =
    StateNotifierProvider.autoDispose<VrPlayerClientNotifier, VrPlayerClientState>(
  (ref) => VrPlayerClientNotifier(),
);

class VrPlayerClientNotifier extends StateNotifier<VrPlayerClientState> {
  VrPlayerClientNotifier() : super(VrPlayerClientState());

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
}

class VrPlayerClientState {
  final bool isVideoLoading;
  final bool isVideoReady;
  final bool isVideoFinished;
  final bool isPlaying;
  final String? duration;
  final int? intDuration;
  final double seekPosition;
  final String? currentPosition;
  final bool isVR;

  VrPlayerClientState({
    this.isVideoLoading = false,
    this.isVideoReady = false,
    this.isVideoFinished = false,
    this.isPlaying = false,
    this.duration,
    this.intDuration,
    this.seekPosition = 0,
    this.currentPosition,
    this.isVR = false,
  });

  VrPlayerClientState copyWith({
    bool? isVideoLoading,
    bool? isVideoReady,
    bool? isVideoFinished,
    bool? isPlaying,
    String? duration,
    int? intDuration,
    double? seekPosition,
    String? currentPosition,
    bool? isVR,
  }) {
    return VrPlayerClientState(
      isVideoLoading: isVideoLoading ?? this.isVideoLoading,
      isVideoReady: isVideoReady ?? this.isVideoReady,
      isVideoFinished: isVideoFinished ?? this.isVideoFinished,
      isPlaying: isPlaying ?? this.isPlaying,
      duration: duration ?? this.duration,
      intDuration: intDuration ?? this.intDuration,
      seekPosition: seekPosition ?? this.seekPosition,
      currentPosition: currentPosition ?? this.currentPosition,
      isVR: isVR ?? this.isVR,
    );
  }
}

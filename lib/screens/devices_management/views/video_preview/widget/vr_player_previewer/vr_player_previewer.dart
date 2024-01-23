import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vr_player/vr_player.dart';
import 'package:vr_trip/models/library_item_model.dart';
import 'package:vr_trip/models/timeline_state_model.dart';
import 'package:vr_trip/providers/device_manager/device_manager_provider.dart';
import 'package:vr_trip/providers/device_manager/types.dart';
import 'package:vr_trip/screens/device_client/screens/vr_player_client/vr_player_client_provider.dart';
import 'package:vr_trip/screens/device_client/screens/vr_player_client/widgets/my_vr_player/my_vr_player.dart';
import 'package:vr_trip/utils/date_utils.dart';
import 'package:vr_trip/utils/logger.dart';
import 'package:vr_trip/utils/vr_player_utils.dart';

const prefix = '[vr_player_host_screen]';

class VrPlayerPreviewer extends ConsumerStatefulWidget {
  final LibraryItemModel? _libraryItem;

  const VrPlayerPreviewer({super.key, LibraryItemModel? libraryItem})
      : _libraryItem = libraryItem;

  @override
  VrPlayerPreviewerState createState() => VrPlayerPreviewerState(_libraryItem);
}

class VrPlayerPreviewerState extends ConsumerState<VrPlayerPreviewer>
    with TickerProviderStateMixin {
  final LibraryItemModel? _libraryItem;

  VrPlayerPreviewerState(this._libraryItem);

  late VrPlayerController _viewPlayerController;

  // Screen size
  late double _playerWidth;
  late double _playerHeight;

  bool showActionBar = true;
  bool isVrMode = false;

  // Using the Riverpod provider to manage the state
  late final vrPlayerClientNotifier = ref.read(vrPlayerClientProvider.notifier);
  late final currentTimeLineItemNotifier =
      ref.read(currentTimeLineItemSP.notifier);

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.initState();
  }

  void onChangePosition(int millis) async {
    vrPlayerClientNotifier.setSeekPosition(millis.toDouble());
    var durationText = millisecondsToDateTime(millis);
    vrPlayerClientNotifier.setCurrentPosition(durationText);

    // Logic for stopping the video on timeline item end
    TimelineItem currentTimelineItem = VrPlayerUtils.computeTimeLineItem(
        millis, _libraryItem!.transcriptObject.timeline);
    currentTimeLineItemNotifier.state = currentTimelineItem;

    if (currentTimelineItem.end == durationText) {
      var timelineState = VrPlayerUtils.getNextTimelineItem(
          currentTimelineItem, _libraryItem!.transcriptObject.timeline);
      await playAndPause(false);
      await setTimeLineState(timelineState);
      Logger.log('$prefix - onChangePosition - found end: $timelineState');
    }
  }

  void onReceiveState(VrState state) {
    switch (state) {
      case VrState.loading:
        vrPlayerClientNotifier.setVideoLoading(true);
        break;
      case VrState.ready:
        vrPlayerClientNotifier.setVideoLoading(false);
        vrPlayerClientNotifier.setVideoReady(true);
        break;
      default:
        break;
    }
  }

  onViewPlayerCreated(
    VrPlayerController controller,
    VrPlayerObserver observer,
  ) {
    try {
      _viewPlayerController = controller;
      observer
        ..onStateChange = onReceiveState
        ..onDurationChange = (millis) {
          Logger.log('$prefix - onDurationChange: $millis');
          vrPlayerClientNotifier.setDuration(
            millisecondsToDateTime(millis),
            millis,
          );
        }
        ..onPositionChange = onChangePosition
        ..onFinishedChange = (isFinished) {
          vrPlayerClientNotifier.setVideoFinished(isFinished);
        };
    } catch (e) {
      Logger.error('$prefix - ERROR - onViewPlayerCreated Observer: $e');
    }

    try {
      _viewPlayerController.loadVideo(videoPath: _libraryItem!.videoPath);
    } catch (e) {
      Logger.error('$prefix - ERROR - loadVideo: $e');
    }
  }

  Future<void> playAndPause(bool startPlay) async {
    if (ref.read(vrPlayerClientProvider).isVideoFinished) {
      Logger.log('$prefix - playAndPause - video finished');
      try {
        await _viewPlayerController.seekTo(0);
        vrPlayerClientNotifier.setSeekPosition(0);

        vrPlayerClientNotifier.setCurrentPosition(millisecondsToDateTime(0));
        vrPlayerClientNotifier.setPlayingStatus(false);

        vrPlayerClientNotifier.setVideoFinished(false);
      } catch (e) {
        Logger.error('$prefix - ERROR - playAndPause seekTo beginning: $e');
      }
    }

    try {
      if (startPlay) {
        Logger.log('$prefix - playAndPause - start play');
        setState(() {
          showActionBar = false;
        });
        await _viewPlayerController.play();
        vrPlayerClientNotifier.setPlayingStatus(true);
      } else {
        Logger.log('$prefix - playAndPause - pause');
        setState(() {
          showActionBar = true;
        });
        await _viewPlayerController.pause();
        vrPlayerClientNotifier.setPlayingStatus(false);
      }
    } catch (e) {
      Logger.error('$prefix - ERROR - playAndPause: $e');
    }
  }

  TimelineStateModel? getTimelineItem(bool? isPrevious) {
    var currentTimelineItem = ref.read(currentTimeLineItemSP);
    if (currentTimelineItem == null) return null;

    if (isPrevious == true) {
      // get previous timeline item
      return VrPlayerUtils.getPreviousTimelineItem(
          currentTimelineItem, _libraryItem!.transcriptObject.timeline);
    }
    // Next timeline item
    return VrPlayerUtils.getNextTimelineItem(
        currentTimelineItem, _libraryItem!.transcriptObject.timeline);
  }

  Future<void> setTimeLineState(TimelineStateModel? newState) async {
    if (newState == null) return;
    await playAndPause(false);
    Logger.log(
        '$prefix - setTimeLineState - ${newState.getCurrentPositionString()}');
    //Set seek position
    await _viewPlayerController.seekTo(newState.getSeekPositionInt());
    vrPlayerClientNotifier.setSeekPosition(newState.getSeekPositionDouble());
    // Update current position text
    vrPlayerClientNotifier
        .setCurrentPosition(newState.getCurrentPositionString());
  }

  @override
  Widget build(BuildContext context) {
    // Accessing the state using the provider
    final vrState = ref.watch(vrPlayerClientProvider);

    ref.listen(videoPreviewEventSP, (previous, next) {
      Logger.log('$prefix - videoPreviewEventSP - $previous/$next');
      if (next != null) {
        switch (next) {
          case VideoPreviewEvent.play:
            playAndPause(true);
            break;
          case VideoPreviewEvent.pause:
            playAndPause(false);
            break;
          case VideoPreviewEvent.forward:
            TimelineStateModel? timeline = getTimelineItem(false);
            Logger.log('$prefix - videoPreviewEventSP - forward - $timeline');
            setTimeLineState(timeline);
            break;
          case VideoPreviewEvent.backward:
            var timeline = getTimelineItem(true);
            setTimeLineState(timeline);
            break;
          default:
            break;
        }

        //Reset the state
        ref.read(videoPreviewEventSP.notifier).state = VideoPreviewEvent.none;
      }
    });

    _playerWidth = MediaQuery.of(context).size.width;
    _playerHeight = _playerWidth / 2;

    return GestureDetector(
      onLongPress: () {
        context.pop();
      },
      onTap: () {
        setState(() {
          showActionBar = !showActionBar;
        });
      },
      child: _libraryItem == null
          ? Container(
              color: Colors.black,
              width: 300,
              height: _playerHeight,
              child: const Center(
                child: Text('No video selected'),
              ),
            )
          : MyVrPlayer(
              onViewPlayerCreated: onViewPlayerCreated,
              playerWidth: _playerWidth,
              playerHeight: _playerHeight,
              showActionBar: showActionBar,
              isPreview: false,
              onChangeSliderPosition: (position) {
                // Currently not used
              },
              fullScreenPressed: () {
                // Your logic for fullScreenPressed here
              },
              cardBoardPressed: () {
                // Your logic for cardBoardPressed here
              },
              seekToPosition: (position) {
                // Your logic for seekToPosition here
                onChangePosition(position);
                _viewPlayerController.seekTo(position);
              },
              playAndPause: () {
                var isVideoPlaying = vrState.isPlaying;
                playAndPause(!isVideoPlaying);
              },
            ),
    );
  }
}

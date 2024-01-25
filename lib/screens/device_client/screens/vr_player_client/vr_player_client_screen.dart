import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vr_player/vr_player.dart';
import 'package:vr_trip/models/library_item_model.dart';
import 'package:vr_trip/models/socket_protocol_message.dart';
import 'package:vr_trip/models/timeline_state_model.dart';
import 'package:vr_trip/providers/settings_provider.dart';
import 'package:vr_trip/providers/socket_client/socket_client_provider.dart';
import 'package:vr_trip/screens/device_client/screens/vr_player_client/vr_player_client_provider.dart';
import 'package:vr_trip/screens/device_client/screens/vr_player_client/widgets/my_vr_player/my_vr_player.dart';
import 'package:vr_trip/services/sockets/socket_protocol/socket_protocol_service.dart';
import 'package:vr_trip/utils/date_utils.dart';
import 'package:vr_trip/utils/libraryItem_utils.dart';
import 'package:vr_trip/utils/logger.dart';
import 'package:vr_trip/utils/vr_player_utils.dart';

const prefix = '[vr_player_host_screen]';

class VrPlayerClientScreen extends ConsumerStatefulWidget {
  final String _serverIp;
  final String _libraryItemPath;

  const VrPlayerClientScreen(
      {super.key, required String serverIp, required String libraryItemPath})
      : _libraryItemPath = libraryItemPath,
        _serverIp = serverIp;

  @override
  VrPlayerClientScreenState createState() =>
      VrPlayerClientScreenState(_libraryItemPath, _serverIp);
}

class VrPlayerClientScreenState extends ConsumerState<VrPlayerClientScreen>
    with TickerProviderStateMixin {
  final String _libraryItemPath;
  final String _serverIp;

  VrPlayerClientScreenState(this._libraryItemPath, this._serverIp);

  late VrPlayerController _viewPlayerController;

  // Screen size
  late double _playerWidth;
  late double _playerHeight;

  bool showActionBar = true;
  bool isVrMode = false;

  LibraryItemModel? _libraryItem;
  TimelineItem? _currentTimelineItem;

  // Using the Riverpod provider to manage the state
  late final vrPlayerClientNotifier = ref.read(vrPlayerClientProvider.notifier);

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    super.initState();

    // Fetching the library item
    (() async {
      var fetchedItem =
          await LibraryItemUtils.fetchLibraryItem(_libraryItemPath);
      if (fetchedItem != null) {
        _libraryItem = fetchedItem;
        _currentTimelineItem = _libraryItem!.transcriptObject.timeline[0];
      }
    })();
  }

  void onChangePosition(int millis) async {
    vrPlayerClientNotifier.setSeekPosition(millis.toDouble());
    var durationText = millisecondsToDateTime(millis);
    vrPlayerClientNotifier.setCurrentPosition(durationText);
    Logger.log('$prefix - onPositionChange: $durationText');

    // Logic for stopping the video on timeline item end
    TimelineItem currentTimelineItem = VrPlayerUtils.computeTimeLineItem(
        millis, _libraryItem!.transcriptObject.timeline);
    _currentTimelineItem = currentTimelineItem;

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
        activateVr();
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

  activateVr() {
    if (!isVrMode) {
      try {
        _viewPlayerController.toggleVRMode();
      } catch (e) {
        Logger.error('$prefix - ERROR - activateVr: $e');
      }
      setState(() {
        isVrMode = true;
      });
    }
  }

  TimelineStateModel? getTimelineItem(bool? isPrevious) {
    if (_currentTimelineItem == null) return null;

    if (isPrevious == true) {
      // get previous timeline item
      return VrPlayerUtils.getPreviousTimelineItem(
          _currentTimelineItem!, _libraryItem!.transcriptObject.timeline);
    }
    // Next timeline item
    return VrPlayerUtils.getNextTimelineItem(
        _currentTimelineItem!, _libraryItem!.transcriptObject.timeline);
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

  setCustomSeekPosition(int millis) async {
    //Set seek position
    await _viewPlayerController.seekTo(millis);
    vrPlayerClientNotifier.setSeekPosition(millis.toDouble());
    // Update current position text
    vrPlayerClientNotifier.setCurrentPosition(millisecondsToDateTime(millis));
  }

  @override
  Widget build(BuildContext context) {
    // Accessing the state using the provider
    final vrState = ref.watch(vrPlayerClientProvider);
    final deviceName = ref.watch(deviceNumberSP);
    final socketClient = ref.watch(socketClientSP);

    _playerWidth = MediaQuery.of(context).size.width;
    _playerHeight = MediaQuery.of(context).size.height;

    ref.listen(clientMessagesSP, (previous, next) {
      final list = next.value;
      if (list != null && list.isNotEmpty) {
        SocketAction action = SocketProtocolService.parseMessage(list.last);
        Logger.log('$prefix - getLastMessage - $action');
        switch (action.type) {
          case SocketActionTypes.play:
            var seekPosition = int.parse(action.value);
            if(seekPosition < 0) {
              Logger.log('getLastMessage - play - seekPosition < 0 - seekPosition: $seekPosition');
              setCustomSeekPosition(seekPosition);
            }
            Logger.log('getLastMessage - play');
            playAndPause(true);
            break;
          case SocketActionTypes.pause:
            var seekPosition = int.parse(action.value);
            setCustomSeekPosition(seekPosition);
            Logger.log('getLastMessage - pause');
            playAndPause(false);
            break;
          case SocketActionTypes.forward:
            TimelineStateModel? timeline = getTimelineItem(false);
            Logger.log('$prefix - videoPreviewEventSP - forward - $timeline');
            setTimeLineState(timeline);
            break;
          case SocketActionTypes.backward:
            var timeline = getTimelineItem(true);
            Logger.log('$prefix - videoPreviewEventSP - backward - $timeline');
            setTimeLineState(timeline);
          default:
            break;
        }
      }
    });

    return Scaffold(
      body: GestureDetector(
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
              )
            : MyVrPlayer(
                onViewPlayerCreated: onViewPlayerCreated,
                playerWidth: _playerWidth,
                playerHeight: _playerHeight,
                showActionBar: showActionBar,
                onChangeSliderPosition: (position) {
                  // Currently not used
                },
                fullScreenPressed: () {
                  // Your logic for fullScreenPressed here
                },
                cardBoardPressed: () {
                  // Your logic for cardBoardPressed here
                  try {
                    _viewPlayerController.toggleVRMode();
                  } catch (e) {
                    Logger.error('$prefix - ERROR - activateVr: $e');
                  }
                  setState(() {
                    isVrMode = !isVrMode;
                  });
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
      ),
    );
  }

  @override
  dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }
}

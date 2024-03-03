import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vr_player/vr_player.dart';
import 'package:vr_trip/models/library_item_model.dart';
import 'package:vr_trip/models/socket_protocol_message.dart';
import 'package:vr_trip/models/timeline_state_model.dart';
import 'package:vr_trip/providers/my_vr_player/my_vr_player_provider.dart';
import 'package:vr_trip/providers/socket_client/socket_client_provider.dart';
import 'package:vr_trip/router/routes.dart';
import 'package:vr_trip/screens/device_client/screens/vr_player_client/widgets/my_vr_player/my_vr_player.dart';
import 'package:vr_trip/services/sockets/socket_protocol/socket_protocol_service.dart';
import 'package:vr_trip/utils/date_utils.dart';
import 'package:vr_trip/utils/libraryItem_utils.dart';
import 'package:vr_trip/utils/logger.dart';
import 'package:vr_trip/utils/vr_player_utils.dart';

const prefix = '[vr_player_host_screen]';

class VrPlayerClientScreen extends ConsumerStatefulWidget {
  final String _libraryItemPath;

  const VrPlayerClientScreen({super.key, required String libraryItemPath})
      : _libraryItemPath = libraryItemPath;

  @override
  VrPlayerClientScreenState createState() =>
      VrPlayerClientScreenState(_libraryItemPath);
}

class VrPlayerClientScreenState extends ConsumerState<VrPlayerClientScreen>
    with TickerProviderStateMixin {
  final String _libraryItemPath;

  VrPlayerClientScreenState(this._libraryItemPath);

  late VrPlayerController _viewPlayerController;

  // Screen size
  late double _playerWidth;
  late double _playerHeight;

  bool showActionBar = true;

  LibraryItemModel? _libraryItem;
  TimelineItem? _currentTimelineItem;
  int _retries = 0;

  late final vrState = ref.watch(myVrPlayerProvider);
  late final vrPlayerNotifier = ref.read(myVrPlayerProvider.notifier);

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    super.initState();

    fetchItemFromPath(_libraryItemPath);
  }

  void fetchItemFromPath(String path) async {
    var fetchedItem = await LibraryItemUtils.fetchLibraryItem(path);
    if (fetchedItem != null) {
      setState(() {
        _libraryItem = fetchedItem;
        _currentTimelineItem = _libraryItem!.transcriptObject.timeline[0];
      });
    }
  }

  onViewPlayerCreated(
    VrPlayerController controller,
    VrPlayerObserver observer,
  ) async {
    try {
      _viewPlayerController = controller;
      observer
        ..onStateChange = onReceiveState
        ..onDurationChange = (millis) {
          Logger.log('$prefix - onDurationChange: $millis');
          vrPlayerNotifier.setDuration(
            millisecondsToDateTime(millis),
            millis,
          );
        }
        ..onPositionChange = onChangePosition
        ..onFinishedChange = (isFinished) {
          vrPlayerNotifier.setVideoFinished(isFinished);
        };

      await _viewPlayerController.loadVideo(videoPath: _libraryItem!.videoPath);
    } catch (e) {
      Logger.error('$prefix - ERROR - onViewPlayerCreated Observer: $e');
      if(_retries < 3){
        setState(() {
          _libraryItem = null;
          _currentTimelineItem = null;
        });
        fetchItemFromPath(_libraryItemPath);
        _retries++;
      }
    }
  }

  void onChangePosition(int millis) async {
    vrPlayerNotifier.setSeekPosition(millis.toDouble());
    var durationText = millisecondsToDateTime(millis);
    vrPlayerNotifier.setCurrentPosition(durationText);
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
        vrPlayerNotifier.setVideoLoading(true);
        break;
      case VrState.ready:
        vrPlayerNotifier.setVideoLoading(false);
        vrPlayerNotifier.setVideoReady(true);
        // TODO: implement socket ready message
        break;
      default:
        Logger.log('$prefix - onReceiveState - state: $state');
        break;
    }
  }

  Future<void> playAndPause(bool startPlay) async {
    if (ref.read(myVrPlayerProvider).isVideoFinished) {
      Logger.log('$prefix - playAndPause - video finished');
      try {
        await _viewPlayerController.seekTo(0);
        vrPlayerNotifier.setSeekPosition(0);

        vrPlayerNotifier.setCurrentPosition(millisecondsToDateTime(0));
        vrPlayerNotifier.setPlayingStatus(false);

        vrPlayerNotifier.setVideoFinished(false);
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
        vrPlayerNotifier.setPlayingStatus(true);
      } else {
        Logger.log('$prefix - playAndPause - pause');
        setState(() {
          showActionBar = true;
        });
        await _viewPlayerController.pause();
        vrPlayerNotifier.setPlayingStatus(false);
      }
    } catch (e) {
      Logger.error('$prefix - ERROR - playAndPause: $e');
    }
  }

  activateVr() {
    if (vrState.isVR == false) {
      try {
        _viewPlayerController.toggleVRMode();
        vrPlayerNotifier.toggleVRMode(true);
        Logger.log('activateVR TRUE');
      } catch (e) {
        Logger.error('$prefix - ERROR - activateVr: $e');
        vrPlayerNotifier.toggleVRMode(false);
      }
    }else{
      Logger.log('activateVR FALSE');
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
    vrPlayerNotifier.setSeekPosition(newState.getSeekPositionDouble());
    // Update current position text
    vrPlayerNotifier.setCurrentPosition(newState.getCurrentPositionString());
  }

  setCustomSeekPosition(int millis) async {
    //Set seek position
    await _viewPlayerController.seekTo(millis);
    vrPlayerNotifier.setSeekPosition(millis.toDouble());
    // Update current position text
    vrPlayerNotifier.setCurrentPosition(millisecondsToDateTime(millis));
  }

  @override
  Widget build(BuildContext context) {
    _playerWidth = MediaQuery.of(context).size.width;
    _playerHeight = MediaQuery.of(context).size.height;

    handleGoBack() {
      context.goNamed(AppRoutes.deviceHost.name);
    }

    handleInvalidateOnDispose() async {
      setState(() {
        _libraryItem = null;
      });
      // wait 1 second to allow the video to stop
      await Future.delayed(const Duration(milliseconds: 300));
      ref.invalidate(myVrPlayerProvider);
      handleGoBack();
    }

    ref.listen(clientMessagesSP, (previous, next) {
      final list = next.value;
      if (list != null && list.isNotEmpty) {
        SocketAction action = SocketProtocolService.parseMessage(list.last);
        Logger.log('$prefix - getLastMessage - $action');
        switch (action.type) {
          case SocketActionTypes.play:
            var seekPosition = int.parse(action.value);
            setCustomSeekPosition(seekPosition);
            Logger.log(
                'getLastMessage - play - seekPosition < 0 - seekPosition: $seekPosition');
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
            playAndPause(false);

            TimelineStateModel? timeline =
                TimelineStateModel.fromJson(jsonDecode(action.value));
            Logger.log('$prefix - videoPreviewEventSP - forward - $timeline');
            setTimeLineState(timeline);
            break;
          case SocketActionTypes.backward:
            playAndPause(false);

            TimelineStateModel? timeline =
                TimelineStateModel.fromJson(jsonDecode(action.value));
            Logger.log('$prefix - videoPreviewEventSP - backward - $timeline');
            setTimeLineState(timeline);
            break;
          case SocketActionTypes.selectVideo:
            if (action.value == 'no_video') {
              handleInvalidateOnDispose();
            } else {
              fetchItemFromPath(action.value);
            }
            break;
          case SocketActionTypes.toggleVR:
            if (vrState.isVideoReady == true && vrState.isVideoLoading == false) {
              activateVr();
            }
            break;

          default:
            break;
        }
      }
    });

    return Scaffold(
      appBar: _libraryItem == null ? AppBar(
        title: const Text('VR Player Client'),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: handleGoBack,
        ),
      ):null,
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
                child: const Center(
                  child: Text('Video non disponibile',
                      style: TextStyle(color: Colors.white60)),
                ),
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
                  try {
                    _viewPlayerController.toggleVRMode();
                    vrPlayerNotifier.toggleVRMode(!vrState.isVR);
                  } catch (e) {
                    Logger.error('$prefix - ERROR - activateVr: $e');
                  }
                },
                seekToPosition: (position) {
                  // Your logic for seekToPosition here
                  onChangePosition(position);
                  _viewPlayerController.seekTo(position);
                },
                playAndPause: () async {
                  var isPlaying = await _viewPlayerController.isPlaying();
                  playAndPause(!isPlaying);
                },
              ),
      ),
    );
  }

  @override
  dispose() {
    super.dispose();
  }
}

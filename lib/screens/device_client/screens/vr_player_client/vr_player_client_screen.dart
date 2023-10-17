import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vr_player/vr_player.dart';
import 'package:vr_trip/models/socket_protocol_message.dart';
import 'package:vr_trip/providers/settings_provider.dart';
import 'package:vr_trip/providers/socket_client/socket_client_provider.dart';
import 'package:vr_trip/providers/socket_client/types.dart';
import 'package:vr_trip/screens/device_client/screens/vr_player_client/vr_player_client_provider.dart';
import 'package:vr_trip/screens/device_client/screens/vr_player_client/widgets/my_vr_player/my_vr_player.dart';
import 'package:vr_trip/services/socket_protocol/socket_protocol_service.dart';
import 'package:vr_trip/utils/date_utils.dart';
import 'package:vr_trip/utils/logger.dart';

const prefix = '[vr_player_host_screen]';

class VrPlayerClientScreen extends ConsumerStatefulWidget {
  final String _videoPath;
  final String _serverIp;

  const VrPlayerClientScreen(
      {super.key, required String serverIp, required String videoPath})
      : _videoPath = videoPath,
        _serverIp = serverIp;

  @override
  VrPlayerClientScreenState createState() =>
      VrPlayerClientScreenState(_videoPath, _serverIp);
}

class VrPlayerClientScreenState extends ConsumerState<VrPlayerClientScreen>
    with TickerProviderStateMixin {
  final String _videoPath;
  final String _serverIp;

  VrPlayerClientScreenState(this._videoPath, this._serverIp);

  late VrPlayerController _viewPlayerController;

  // Screen size
  late double _playerWidth;
  late double _playerHeight;

  bool showActionBar = true;
  bool isVrMode = false;

  // Using the Riverpod provider to manage the state
  late final vrPlayerClientNotifier = ref.read(vrPlayerClientProvider.notifier);

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    super.initState();
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
          vrPlayerClientNotifier.setDuration(
            millisecondsToDateTime(millis),
            millis,
          );
        }
        ..onPositionChange = (int millis) {
          vrPlayerClientNotifier.setSeekPosition(millis.toDouble());
        }
        ..onFinishedChange = (isFinished) {
          vrPlayerClientNotifier.setVideoFinished(isFinished);
        };
    } catch (e) {
      Logger.error('$prefix - ERROR - onViewPlayerCreated Observer: $e');
    }

    try {
      _viewPlayerController.loadVideo(videoPath: _videoPath);
    } catch (e) {
      Logger.error('$prefix - ERROR - loadVideo: $e');
    }
  }

  Future<void> playAndPause(bool startPlay) async {
    if (ref.read(vrPlayerClientProvider).isVideoFinished) {
      try {
        await _viewPlayerController.seekTo(0);
      } catch (e) {
        Logger.error('$prefix - ERROR - playAndPause seekTo beginning: $e');
      }
    }

    try {
      if (startPlay && !ref.read(vrPlayerClientProvider).isPlaying) {
        activateVr();
        setState(() {
          showActionBar = false;
        });
        await _viewPlayerController.play();
        vrPlayerClientNotifier.setPlayingStatus(true);
      } else if (!startPlay && ref.read(vrPlayerClientProvider).isPlaying) {
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

  @override
  Widget build(BuildContext context) {
    // Accessing the state using the provider
    final vrState = ref.watch(vrPlayerClientProvider);
    final deviceName = ref.watch(deviceNumberSP);

    _playerWidth = MediaQuery.of(context).size.width;
    _playerHeight = MediaQuery.of(context).size.height;

    ref.listen(
        clientMessagesSP(SocketClientProviderParams(
            serverIp: _serverIp,
            deviceName: deviceName ?? '')), (previous, next) {
      final list = next.value;
      if (list != null && list.isNotEmpty) {
        SocketAction action = SocketProtocolService.parseMessage(list.last);
        switch (action.type) {
          case SocketActionTypes.play:
            Logger.log('getLastMessage - play');
            playAndPause(true);
            break;
          case SocketActionTypes.pause:
            Logger.log('getLastMessage - pause');
            playAndPause(false);
            break;
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
        child: MyVrPlayer(
          onViewPlayerCreated: onViewPlayerCreated,
          playerWidth: _playerWidth,
          playerHeight: _playerHeight,
          showActionBar: showActionBar,
          onChangeSliderPosition: (position) {
            // Your logic for onChangeSliderPosition here
          },
          fullScreenPressed: () {
            // Your logic for fullScreenPressed here
          },
          cardBoardPressed: () {
            // Your logic for cardBoardPressed here
          },
          seekToPosition: (position) {
            // Your logic for seekToPosition here
          },
          playAndPause: () {},
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

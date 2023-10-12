import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vr_player/vr_player.dart';
import 'package:vr_trip/models/socket_protocol_message.dart';
import 'package:vr_trip/screens/device_host/screens/vr_player_host/widgets/my_vr_player/my_vr_player.dart';
import 'package:vr_trip/services/network_discovery_client/network_discovery_client_provider.dart';
import 'package:vr_trip/services/socket_protocol/socket_protocol_service.dart';
import 'package:vr_trip/utils/date_utils.dart';
import 'package:vr_trip/utils/logger.dart';

class VrPlayerHostScreen extends ConsumerStatefulWidget {
  final String _videoPath;
  final String _serverIp;

  const VrPlayerHostScreen(
      {super.key, required String serverIp, required String videoPath})
      : _videoPath = videoPath,
        _serverIp = serverIp;

  @override
  VrPlayerHostScreenState createState() =>
      VrPlayerHostScreenState(_videoPath, _serverIp);
}

class VrPlayerHostScreenState extends ConsumerState<VrPlayerHostScreen>
    with TickerProviderStateMixin {
  final String _videoPath;
  final String _serverIp;

  VrPlayerHostScreenState(this._videoPath, this._serverIp);

  late VrPlayerController _viewPlayerController;

  // Screen size
  late double _playerWidth;
  late double _playerHeight;

  // Video Status
  bool isVideoLoading = false;
  bool isVideoReady = false;
  bool _isVideoFinished = false;
  bool _isPlaying = false;

  // Video Duration
  String? _duration;
  int? _intDuration;

  // Video Position
  double _seekPosition = 0;
  String? _currentPosition;

  // Video Settings
  bool _isVR = false;

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
        setState(() {
          isVideoLoading = true;
        });
        break;
      case VrState.ready:
        setState(() {
          isVideoLoading = false;
          isVideoReady = true;
        });
        break;
      default:
        break;
    }
  }

  void onReceiveDuration(int millis) {
    setState(() {
      _intDuration = millis;
      _duration = millisecondsToDateTime(millis);
    });
  }

  void onChangePosition(int millis) {
    setState(() {
      _currentPosition = millisecondsToDateTime(millis);
      _seekPosition = millis.toDouble();
    });
  }

  void onReceiveEnded(bool isFinished) {
    setState(() {
      _isVideoFinished = isFinished;
    });
  }

  void onViewPlayerCreated(
    VrPlayerController controller,
    VrPlayerObserver observer,
  ) {
    _viewPlayerController = controller;
    observer
      ..onStateChange = onReceiveState
      ..onDurationChange = onReceiveDuration
      ..onPositionChange = onChangePosition
      ..onFinishedChange = onReceiveEnded;
    _viewPlayerController.loadVideo(videoPath: _videoPath);
  }

  Future<void> playAndPause(bool startPlay) async {
    if (_isVideoFinished) {
      await _viewPlayerController.seekTo(0);
    }

    if (startPlay && !_isPlaying) {
      activeteVr();
      await _viewPlayerController.play();
    } else if (!startPlay && _isPlaying) {
      await _viewPlayerController.pause();
    }

    setState(() {
      _isPlaying = startPlay;
      _isVideoFinished = false;
    });
  }

  activeteVr() {
    if (!_isVR) {
      _viewPlayerController.toggleVRMode();
      setState(() {
        _isVR = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _playerWidth = MediaQuery.of(context).size.width;
    _playerHeight = MediaQuery.of(context).size.height;

    ref.listen(hostMessagesSP(_serverIp), (previous, next) {
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
          child: MyVrPlayer(
            onViewPlayerCreated: onViewPlayerCreated,
            playerWidth: _playerWidth,
            playerHeight: _playerHeight,
          )),
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

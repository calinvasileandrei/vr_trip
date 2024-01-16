import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:vr_player/vr_player.dart';
import 'package:vr_trip/models/library_item_model.dart';
import 'package:vr_trip/utils/libraryItem_utils.dart';

class VrPlayerScreen extends StatefulWidget {
  final String _libraryItemPath;

  const VrPlayerScreen({super.key, required String libraryItemPath})
      : _libraryItemPath = libraryItemPath;

  @override
  _VrPlayerScreenState createState() => _VrPlayerScreenState(_libraryItemPath);
}

class _VrPlayerScreenState extends State<VrPlayerScreen>
    with TickerProviderStateMixin {
  final String _libraryItemPath;
  LibraryItemModel? _libraryItem;

  _VrPlayerScreenState(this._libraryItemPath);

  late VrPlayerController _viewPlayerController;
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isShowingBar = false;
  bool _isPlaying = false;
  bool _isFullScreen = true;
  bool _isVideoFinished = false;
  bool _isLandscapeOrientation = true;
  bool _isVolumeSliderShown = false;
  bool _isVolumeEnabled = true;
  late double _playerWidth;
  late double _playerHeight;
  String? _duration;
  int? _intDuration;
  bool isVideoLoading = false;
  bool isVideoReady = false;
  String? _currentPosition;
  double _currentSliderValue = 0.1;
  double _seekPosition = 0;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
    _toggleShowingBar();
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
      }
    })();
  }

  @override
  dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  void _toggleShowingBar() {
    switchVolumeSliderDisplay(show: false);

    _isShowingBar = !_isShowingBar;
    if (_isShowingBar) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    _playerWidth = MediaQuery.of(context).size.width;
    _playerHeight =
        _isFullScreen ? MediaQuery.of(context).size.height : _playerWidth / 2;
    _isLandscapeOrientation =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      body: GestureDetector(
        onLongPress: () {
          context.pop();
        },
        onTap: _toggleShowingBar,
        child: _libraryItem == null
            ? Container(
                color: Colors.black,
              )
            : Stack(
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  VrPlayer(
                    x: 0,
                    y: 0,
                    onCreated: onViewPlayerCreated,
                    width: _playerWidth,
                    height: _playerHeight,
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: FadeTransition(
                      opacity: _animation,
                      child: ColoredBox(
                        color: Colors.black,
                        child: Row(
                          children: <Widget>[
                            IconButton(
                              icon: Icon(
                                _isVideoFinished
                                    ? Icons.replay
                                    : _isPlaying
                                        ? Icons.pause
                                        : Icons.play_arrow,
                                color: Colors.white,
                              ),
                              onPressed: playAndPause,
                            ),
                            Text(
                              _currentPosition?.toString() ?? '00:00',
                              style: const TextStyle(color: Colors.white),
                            ),
                            Expanded(
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: Colors.amberAccent,
                                  inactiveTrackColor: Colors.grey,
                                  trackHeight: 5,
                                  thumbColor: Colors.white,
                                  thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 8,
                                  ),
                                  overlayColor: Colors.purple.withAlpha(32),
                                  overlayShape: const RoundSliderOverlayShape(
                                    overlayRadius: 14,
                                  ),
                                ),
                                child: Slider(
                                  value: _seekPosition,
                                  max: _intDuration?.toDouble() ?? 0,
                                  onChangeEnd: (value) {
                                    _viewPlayerController.seekTo(value.toInt());
                                  },
                                  onChanged: (value) {
                                    onChangePosition(value.toInt());
                                  },
                                ),
                              ),
                            ),
                            Text(
                              _duration?.toString() ?? '99:99',
                              style: const TextStyle(color: Colors.white),
                            ),
                            if (_isFullScreen || _isLandscapeOrientation)
                              IconButton(
                                icon: Icon(
                                  _isVolumeEnabled
                                      ? Icons.volume_up_rounded
                                      : Icons.volume_off_rounded,
                                  color: Colors.white,
                                ),
                                onPressed: () =>
                                    switchVolumeSliderDisplay(show: true),
                              ),
                            IconButton(
                              icon: Icon(
                                _isFullScreen
                                    ? Icons.fullscreen_exit
                                    : Icons.fullscreen,
                                color: Colors.white,
                              ),
                              onPressed: fullScreenPressed,
                            ),
                            if (_isFullScreen)
                              IconButton(
                                icon: Icon(
                                  Icons.ad_units,
                                  color: Colors.white,
                                ),
                                onPressed: cardBoardPressed,
                              )
                            else
                              Container(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    height: 180,
                    right: 4,
                    top: MediaQuery.of(context).size.height / 4,
                    child: _isVolumeSliderShown
                        ? RotatedBox(
                            quarterTurns: 3,
                            child: Slider(
                              value: _currentSliderValue,
                              divisions: 10,
                              onChanged: onChangeVolumeSlider,
                            ),
                          )
                        : const SizedBox(),
                  ),
                ],
              ),
      ),
    );
  }

  void cardBoardPressed() {
    _viewPlayerController.toggleVRMode();
  }

  Future<void> fullScreenPressed() async {
    await _viewPlayerController.fullScreen();
    setState(() {
      _isFullScreen = !_isFullScreen;
    });

    if (_isFullScreen) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
      ]);
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: [],
      );
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: SystemUiOverlay.values,
      );
    }
  }

  Future<void> playAndPause() async {
    if (_isVideoFinished) {
      await _viewPlayerController.seekTo(0);
    }

    if (_isPlaying) {
      await _viewPlayerController.pause();
    } else {
      await _viewPlayerController.play();
    }

    setState(() {
      _isPlaying = !_isPlaying;
      _isVideoFinished = false;
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
    _viewPlayerController.loadVideo(
        /* videoUrl: 'https://cdn.bitmovin.com/content/assets/playhouse-vr/m3u8s/105560.m3u8', */
        videoPath: _libraryItem!.videoPath);
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
      case VrState.buffering:
      case VrState.idle:
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

  // ignore: avoid_positional_boolean_parameters
  void onReceiveEnded(bool isFinished) {
    setState(() {
      _isVideoFinished = isFinished;
    });
  }

  void onChangeVolumeSlider(double value) {
    _viewPlayerController.setVolume(value);
    setState(() {
      _isVolumeEnabled = value != 0;
      _currentSliderValue = value;
    });
  }

  void switchVolumeSliderDisplay({required bool show}) {
    setState(() {
      _isVolumeSliderShown = show;
    });
  }

  String millisecondsToDateTime(int milliseconds) =>
      setDurationText(Duration(milliseconds: milliseconds));

  String setDurationText(Duration duration) {
    String twoDigits(int n) {
      if (n >= 10) return '$n';
      return '0$n';
    }

    final twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    final twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds';
  }
}

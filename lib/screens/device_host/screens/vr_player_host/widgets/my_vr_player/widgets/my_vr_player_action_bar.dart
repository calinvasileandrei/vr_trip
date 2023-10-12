import 'package:flutter/material.dart';

class MyVrPlayerActionBar extends StatelessWidget {
  final bool isVideoFinished;
  final bool isPlaying;
  final String? currentPosition;
  final int? intDuration;
  final String? duration;
  final double seekPosition;
  final Function() playAndPause;
  final Function(int) onChangeSliderPosition;
  final Function() fullScreenPressed;
  final Function() cardBoardPressed;
  final Function(int) seekToPosition;

  const MyVrPlayerActionBar({
    super.key,
    required this.isVideoFinished,
    required this.isPlaying,
    required this.currentPosition,
    required this.intDuration,
    required this.duration,
    required this.seekPosition,
    required this.playAndPause,
    required this.onChangeSliderPosition,
    required this.fullScreenPressed,
    required this.cardBoardPressed,
    required this.seekToPosition,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: ColoredBox(
        color: Colors.black,
        child: Row(
          children: <Widget>[
            IconButton(
              icon: Icon(
                isVideoFinished
                    ? Icons.replay
                    : isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                color: Colors.white,
              ),
              onPressed: playAndPause,
            ),
            Text(
              currentPosition?.toString() ?? '00:00',
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
                  value: seekPosition,
                  max: intDuration?.toDouble() ?? 0,
                  onChangeEnd: (value) {
                    seekToPosition(value.toInt());
                  },
                  onChanged: (value) {
                    onChangeSliderPosition(value.toInt());
                  },
                ),
              ),
            ),
            Text(
              duration?.toString() ?? '99:99',
              style: const TextStyle(color: Colors.white),
            ),
            IconButton(
              icon: const Icon(
                Icons.ad_units,
                color: Colors.white,
              ),
              onPressed: cardBoardPressed,
            )
          ],
        ),
      ),
    );
  }
}

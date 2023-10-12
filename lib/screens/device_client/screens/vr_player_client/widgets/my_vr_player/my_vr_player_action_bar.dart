import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vr_trip/screens/device_client/screens/vr_player_client/vr_player_client_provider.dart';

class MyVrPlayerActionBar extends ConsumerWidget {
  final Function() playAndPause;
  final Function(int) onChangeSliderPosition;
  final Function() cardBoardPressed;
  final Function(int) seekToPosition;

  const MyVrPlayerActionBar({
    super.key,
    required this.playAndPause,
    required this.onChangeSliderPosition,
    required this.cardBoardPressed,
    required this.seekToPosition,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the state using the provider
    final vrState = ref.watch(vrPlayerClientProvider);

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
                vrState.isVideoFinished
                    ? Icons.replay
                    : vrState.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                color: Colors.white,
              ),
              onPressed: playAndPause,
            ),
            Text(
              vrState.currentPosition?.toString() ?? '00:00',
              style: const TextStyle(color: Colors.white),
            ),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                    // ... [unchanged theme data]
                    ),
                child: Slider(
                  value: vrState.seekPosition,
                  max: vrState.intDuration?.toDouble() ?? 0,
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
              vrState.duration?.toString() ?? '99:99',
              style: const TextStyle(color: Colors.white),
            ),
            IconButton(
              icon: const Icon(
                Icons.ad_units,
                color: Colors.white,
              ),
              onPressed: cardBoardPressed,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:vr_player/vr_player.dart';
import 'package:vr_trip/screens/device_client/screens/vr_player_client/widgets/my_vr_player/my_vr_player_action_bar.dart';

class MyVrPlayer extends StatelessWidget {
  final Function(VrPlayerController, VrPlayerObserver) onViewPlayerCreated;
  final double playerWidth;
  final double playerHeight;
  final bool showActionBar;
  final Function() playAndPause;
  final Function(int) onChangeSliderPosition;
  final Function() fullScreenPressed;
  final Function() cardBoardPressed;
  final Function(int) seekToPosition;

  const MyVrPlayer({
    super.key,
    required this.onViewPlayerCreated,
    required this.playerWidth,
    required this.playerHeight,
    required this.showActionBar,
    required this.playAndPause,
    required this.onChangeSliderPosition,
    required this.fullScreenPressed,
    required this.cardBoardPressed,
    required this.seekToPosition,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        VrPlayer(
          x: 0,
          y: 0,
          onCreated: onViewPlayerCreated,
          width: playerWidth,
          height: playerHeight,
        ),
        // if (showActionBar)
          MyVrPlayerActionBar(
            playAndPause: playAndPause,
            onChangeSliderPosition: onChangeSliderPosition,
            cardBoardPressed: cardBoardPressed,
            seekToPosition: seekToPosition,
          ),
      ],
    );
  }
}

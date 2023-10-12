import 'package:flutter/material.dart';
import 'package:vr_player/vr_player.dart';

class MyVrPlayer extends StatelessWidget {
  final Function(VrPlayerController, VrPlayerObserver) onViewPlayerCreated;
  final double playerWidth;
  final double playerHeight;

  const MyVrPlayer(
      {super.key,
      required this.onViewPlayerCreated,
      required this.playerWidth,
      required this.playerHeight});

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
      ],
    );
  }
}

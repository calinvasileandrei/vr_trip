

/*
*
*
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
                          icon: const Icon(
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
*
* */

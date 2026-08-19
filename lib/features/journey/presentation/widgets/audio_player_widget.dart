import 'package:shimmer/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:math';

class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;
  final bool isMini;

  const AudioPlayerWidget({
    Key? key,
    required this.audioUrl,
    this.isMini = false,
  }) : super(key: key);

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _audioPlayer;
  static AudioPlayer? _currentlyPlaying;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initPlayer(widget.audioUrl);
  }

  @override
  void didUpdateWidget(AudioPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.audioUrl != widget.audioUrl) {
      _initPlayer(widget.audioUrl);
    }
  }

  void _initPlayer(String urlOrPath) {
    if (urlOrPath.startsWith('http')) {
      _audioPlayer.setUrl(urlOrPath).catchError((e) {
        debugPrint('Error loading remote audio: $e');
        return null;
      });
    } else {
      _audioPlayer.setFilePath(urlOrPath).catchError((e) {
        debugPrint('Error loading local audio: $e');
        return null;
      });
    }
  }

  @override
  void dispose() {
    if (_currentlyPlaying == _audioPlayer) {
      _currentlyPlaying = null;
    }
    _audioPlayer.dispose();
    super.dispose();
  }

  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
        _audioPlayer.positionStream,
        _audioPlayer.bufferedPositionStream,
        _audioPlayer.durationStream,
        (position, bufferedPosition, duration) =>
            PositionData(position, bufferedPosition, duration ?? Duration.zero),
      );

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: widget.isMini ? EdgeInsets.zero : const EdgeInsets.only(top: 12),
      padding: widget.isMini
          ? const EdgeInsets.symmetric(vertical: 4)
          : const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: widget.isMini
          ? null
          : BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: 0.5),
              ),
            ),
      child: StreamBuilder<PlayerState>(
        stream: _audioPlayer.playerStateStream,
        builder: (context, snapshot) {
          final playerState = snapshot.data;
          final processingState = playerState?.processingState;
          final playing = playerState?.playing;
          final isLoading =
              processingState == ProcessingState.loading ||
              processingState == ProcessingState.buffering;

          Widget button;
          if (isLoading) {
            button = IconButton(
              icon: const Icon(Icons.play_circle),
              iconSize: 36.0,
              color: theme.colorScheme.primary,
              disabledColor: theme.colorScheme.primary,
              onPressed: null,
            );
          } else if (playing != true) {
            button = IconButton(
              icon: const Icon(Icons.play_circle),
              iconSize: 36.0,
              color: theme.colorScheme.primary,
              onPressed: () {
                if (_currentlyPlaying != null &&
                    _currentlyPlaying != _audioPlayer) {
                  _currentlyPlaying!.pause();
                }
                _currentlyPlaying = _audioPlayer;
                _audioPlayer.play();
              },
            );
          } else if (processingState != ProcessingState.completed) {
            button = IconButton(
              icon: const Icon(Icons.pause_circle),
              iconSize: 36.0,
              color: theme.colorScheme.primary,
              onPressed: _audioPlayer.pause,
            );
          } else {
            button = IconButton(
              icon: const Icon(Icons.replay_circle_filled),
              iconSize: 36.0,
              color: theme.colorScheme.primary,
              onPressed: () {
                if (_currentlyPlaying != null &&
                    _currentlyPlaying != _audioPlayer) {
                  _currentlyPlaying!.pause();
                }
                _currentlyPlaying = _audioPlayer;
                _audioPlayer.seek(Duration.zero);
                _audioPlayer.play();
              },
            );
          }

          final content = Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4.0, right: 4.0),
                child: button,
              ),
              Expanded(
                child: StreamBuilder<PositionData>(
                  stream: _positionDataStream,
                  builder: (context, snapshot) {
                    final positionData = snapshot.data;
                    final position = positionData?.position ?? Duration.zero;
                    final duration = positionData?.duration ?? Duration.zero;

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        isLoading
                            ? Shimmer.fromColors(
                                baseColor: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.1),
                                highlightColor: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.3),
                                child: SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    trackHeight: 4,
                                    thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 6,
                                    ),
                                    overlayShape: const RoundSliderOverlayShape(
                                      overlayRadius: 12,
                                    ),
                                    activeTrackColor: theme.colorScheme.primary,
                                    inactiveTrackColor: theme
                                        .colorScheme
                                        .primary
                                        .withValues(alpha: 0.2),
                                    thumbColor: theme.colorScheme.primary,
                                  ),
                                  child: Slider(
                                    value: 0.0,
                                    max: 1.0,
                                    onChanged: null,
                                  ),
                                ),
                              )
                            : SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  trackHeight: 4,
                                  thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 6,
                                  ),
                                  overlayShape: const RoundSliderOverlayShape(
                                    overlayRadius: 12,
                                  ),
                                  activeTrackColor: theme.colorScheme.primary,
                                  inactiveTrackColor: theme.colorScheme.primary
                                      .withValues(alpha: 0.2),
                                  thumbColor: theme.colorScheme.primary,
                                ),
                                child: Slider(
                                  value: min(
                                    position.inMilliseconds.toDouble(),
                                    duration.inMilliseconds.toDouble(),
                                  ),
                                  max: duration.inMilliseconds.toDouble() > 0
                                      ? duration.inMilliseconds.toDouble()
                                      : 1.0,
                                  onChanged: (value) {
                                    _audioPlayer.seek(
                                      Duration(milliseconds: value.round()),
                                    );
                                  },
                                ),
                              ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Voice Note',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                isLoading
                                    ? '--:--'
                                    : (position.inMilliseconds == 0 &&
                                          duration.inMilliseconds > 0)
                                    ? _formatDuration(duration)
                                    : (duration.inMilliseconds > 0)
                                    ? '${_formatDuration(position)} / ${_formatDuration(duration)}'
                                    : _formatDuration(position),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          );

          return content;
        },
      ),
    );
  }
}

class PositionData {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;

  PositionData(this.position, this.bufferedPosition, this.duration);
}

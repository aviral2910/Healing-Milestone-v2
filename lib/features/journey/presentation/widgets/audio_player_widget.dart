import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:math';

class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;

  const AudioPlayerWidget({Key? key, required this.audioUrl}) : super(key: key);

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.setUrl(widget.audioUrl).catchError((e) {
      debugPrint('Error loading audio: $e');
      return null;
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          _audioPlayer.positionStream,
          _audioPlayer.bufferedPositionStream,
          _audioPlayer.durationStream,
          (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero));

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
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              StreamBuilder<PlayerState>(
                stream: _audioPlayer.playerStateStream,
                builder: (context, snapshot) {
                  final playerState = snapshot.data;
                  final processingState = playerState?.processingState;
                  final playing = playerState?.playing;
                  Widget button;
                  if (processingState == ProcessingState.loading ||
                      processingState == ProcessingState.buffering) {
                    button = Container(
                      margin: const EdgeInsets.all(8.0),
                      width: 32.0,
                      height: 32.0,
                      child: CircularProgressIndicator(
                        strokeWidth: 3, 
                        color: theme.colorScheme.primary,
                      ),
                    );
                  } else if (playing != true) {
                    button = IconButton(
                      icon: const Icon(Icons.play_circle),
                      iconSize: 42.0,
                      color: theme.colorScheme.primary,
                      onPressed: _audioPlayer.play,
                    );
                  } else if (processingState != ProcessingState.completed) {
                    button = IconButton(
                      icon: const Icon(Icons.pause_circle),
                      iconSize: 42.0,
                      color: theme.colorScheme.primary,
                      onPressed: _audioPlayer.pause,
                    );
                  } else {
                    button = IconButton(
                      icon: const Icon(Icons.replay_circle_filled),
                      iconSize: 42.0,
                      color: theme.colorScheme.primary,
                      onPressed: () => _audioPlayer.seek(Duration.zero),
                    );
                  }
                  
                  return Padding(
                    padding: const EdgeInsets.only(left: 4.0, right: 4.0),
                    child: button,
                  );
                },
              ),
              Expanded(
                child: StreamBuilder<PositionData>(
                  stream: _positionDataStream,
                  builder: (context, snapshot) {
                    final positionData = snapshot.data;
                    final position = positionData?.position ?? Duration.zero;
                    final duration = positionData?.duration ?? Duration.zero;
                    
                    return SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 6,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                        activeTrackColor: theme.colorScheme.primary,
                        inactiveTrackColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                        thumbColor: theme.colorScheme.primary,
                      ),
                      child: Slider(
                        value: min(position.inMilliseconds.toDouble(), duration.inMilliseconds.toDouble()),
                        max: duration.inMilliseconds.toDouble() > 0 ? duration.inMilliseconds.toDouble() : 1.0,
                        onChanged: (value) {
                          _audioPlayer.seek(Duration(milliseconds: value.round()));
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          StreamBuilder<PositionData>(
            stream: _positionDataStream,
            builder: (context, snapshot) {
              final positionData = snapshot.data;
              final position = positionData?.position ?? Duration.zero;
              final duration = positionData?.duration ?? Duration.zero;
              
              return Padding(
                padding: const EdgeInsets.only(right: 24.0, bottom: 4.0),
                child: Text(
                  (position.inMilliseconds == 0 && duration.inMilliseconds > 0)
                      ? _formatDuration(duration)
                      : (duration.inMilliseconds > 0)
                          ? '${_formatDuration(position)} / ${_formatDuration(duration)}'
                          : _formatDuration(position),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            },
          ),
        ],
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
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:healing_milestones/core/providers/audio_player_provider.dart';
import 'package:healing_milestones/core/models/story_model.dart';
import 'package:healing_milestones/shared/widgets/audio_visualizer.dart';

class ExpandedTTSBar extends ConsumerWidget {
  final StoryModel story;
  const ExpandedTTSBar({super.key, required this.story});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final audioState = ref.watch(audioPlayerProvider);
    final audioNotifier = ref.read(audioPlayerProvider.notifier);

    final isThisStoryActive = audioState.currentStory?.storyId == story.storyId;
    final isPlaying = isThisStoryActive && audioState.isPlaying;
    final progress = isThisStoryActive ? audioState.progress : 0.0;


    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Top Section: Label & Menus
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              Icon(
                Icons.headphones_rounded,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'AUDIO STORY',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    letterSpacing: 1.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Speed Menu
              PopupMenuButton<double>(
                tooltip: 'Playback Speed',
                offset: const Offset(0, 30),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.speed_rounded, size: 14, color: theme.colorScheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        '${audioState.playbackSpeed}x',
                        style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                onSelected: (val) async {
                  await audioNotifier.changeSpeed(val);
                },
                itemBuilder: (context) => [0.5, 0.75, 1.0, 1.25, 1.5, 2.0]
                    .map(
                      (speed) => PopupMenuItem(
                        value: speed,
                        child: Text('${speed}x', style: TextStyle(color: theme.colorScheme.onSurface)),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(width: 8),
              // Voice Menu (Icon only as requested previously)
              if (audioState.availableVoices.isNotEmpty)
                PopupMenuButton<Map<String, String>>(
                  tooltip: 'Change Voice',
                  offset: const Offset(0, 30),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.record_voice_over_rounded, size: 14, color: theme.colorScheme.primary),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_drop_down, size: 14, color: theme.colorScheme.primary),
                      ],
                    ),
                  ),
                  onSelected: (voice) async {
                    await audioNotifier.changeVoice(voice);
                  },
                  itemBuilder: (context) => audioState.availableVoices
                      .map(
                        (voice) => PopupMenuItem(
                          value: voice,
                          child: Text(
                            voice['displayName'] ?? voice['name'] ?? 'Unknown Voice',
                            style: TextStyle(color: theme.colorScheme.onSurface),
                          ),
                        ),
                      )
                      .toList(),
                ),
            ],
          ),
        ),
        // Divider
        Divider(height: 1, color: theme.colorScheme.primary.withValues(alpha: 0.1)),
        // Bottom Section: Play Button, Visualizer, Slider
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Giant Play Button
              GestureDetector(
                onTap: () async {
                  audioNotifier.togglePlayPause(story);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isPlaying ? theme.colorScheme.surface : theme.colorScheme.primary,
                    shape: BoxShape.circle,
                    border: isPlaying ? Border.all(color: theme.colorScheme.primary, width: 2) : null,
                  ),
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.only(left: isPlaying ? 0 : 2.0),
                      child: Icon(
                        isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        color: isPlaying ? theme.colorScheme.primary : theme.colorScheme.onPrimary,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Visualizer and Slider Stack
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AudioVisualizer(
                      isPlaying: isPlaying,
                      color: theme.colorScheme.primary,
                      barCount: 24,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 2,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                              activeTrackColor: theme.colorScheme.primary,
                              inactiveTrackColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                              thumbColor: theme.colorScheme.primary,
                            ),
                            child: Slider(
                              value: progress.isNaN ? 0.0 : progress.clamp(0.0, 1.0),
                              onChanged: isThisStoryActive ? (val) {
                                audioNotifier.cancelTimer();
                                audioNotifier.updateProgress(val);
                              } : null,
                              onChangeEnd: isThisStoryActive ? (val) {
                                if (isPlaying) { audioNotifier.startPlaybackFrom(val); }
                              } : null,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${((progress.isNaN ? 0.0 : progress.clamp(0.0, 1.0)) * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

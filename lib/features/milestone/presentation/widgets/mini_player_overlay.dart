import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:healing_milestones/shared/widgets/audio_visualizer.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:healing_milestones/core/providers/audio_player_provider.dart';
import 'package:healing_milestones/core/router/app_routes.dart';
import 'package:healing_milestones/core/router/app_router.dart';
import 'expanded_tts_bar.dart';
import 'package:go_router/go_router.dart';

class MiniPlayerExpandedNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void toggle() => state = !state;
  void setExpanded(bool val) => state = val;
}

final miniPlayerExpandedProvider =
    NotifierProvider<MiniPlayerExpandedNotifier, bool>(
      MiniPlayerExpandedNotifier.new,
    );

class MiniPlayerOverlay extends ConsumerWidget {
  const MiniPlayerOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use GoRouterState to reactively get the current route!
    final goRouterState = GoRouterState.of(context);
    final currentRoute = goRouterState.uri.toString();
    final isHome = currentRoute == '/' || currentRoute == '/home';

    final audioState = ref.watch(audioPlayerProvider);

    final currentStory = audioState.currentStory;
    final isExpanded = ref.watch(miniPlayerExpandedProvider);

    // Auto-collapse when navigating away
    ref.listen(currentRouteProvider, (prev, next) {
      if (prev != next && ref.read(miniPlayerExpandedProvider)) {
        ref.read(miniPlayerExpandedProvider.notifier).setExpanded(false);
      }
    });

    if (currentStory == null) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Stack(
      children: [
        // Backdrop for bottom sheet effect
        if (isExpanded)
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                ref
                    .read(miniPlayerExpandedProvider.notifier)
                    .setExpanded(false);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                color: Colors.black.withValues(alpha: 0.4),
              ),
            ),
          ),

        // Player
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          bottom: isHome ? (MediaQuery.of(context).padding.bottom + 60) : 0,
          left: 0,
          right: 0,
          child: Material(
            color: Colors.transparent,
            child: Dismissible(
              key: ValueKey(currentStory.storyId),
              direction: isExpanded
                  ? DismissDirection.none
                  : DismissDirection.startToEnd,
              onDismissed: (direction) {
                ref.read(audioPlayerProvider.notifier).closePlayer();
              },
              child: GestureDetector(
                onTap: () {
                  if (isExpanded) return;
                  ref
                      .read(miniPlayerExpandedProvider.notifier)
                      .setExpanded(true);
                },
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.bottomCenter,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                      child: Container(
                        height: isExpanded
                            ? null
                            : (72 +
                                  (!isHome
                                      ? MediaQuery.of(context).padding.bottom
                                      : 0)),
                        padding: EdgeInsets.only(
                          bottom: !isHome
                              ? (MediaQuery.of(context).padding.bottom + 8)
                              : 8,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceBright.withValues(
                            alpha: 0.4,
                          ),

                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                          ), // Slight rounding for the expanded/mini player looks premium

                          border: Border(
                            top: BorderSide(
                              color: theme.colorScheme.outline.withValues(
                                alpha: 0.2,
                              ),
                              width: 1,
                            ),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                          ),
                          child: SingleChildScrollView(
                            physics: const NeverScrollableScrollPhysics(),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isExpanded) ...[
                                  // Expanded View (Full TTS Bar)
                                  GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      String path = AppRoutes.storyDetailPath
                                          .replaceAll(
                                            ':id',
                                            currentStory.storyId,
                                          );
                                      if (currentRoute == path) return;
                                      ref.read(routerProvider).push(path);
                                    },
                                    child: Column(
                                      children: [
                                        // Top bar for shrink icon
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 16,
                                            bottom: 4,
                                            right: 8,
                                            left: 16,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      currentStory
                                                              .heading
                                                              .isNotEmpty
                                                          ? currentStory.heading
                                                          : 'Audio Story',
                                                      style: TextStyle(
                                                        color: theme
                                                            .colorScheme
                                                            .onSurface,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      (!currentStory
                                                              .displayAuthorName)
                                                          ? 'Anonymous'
                                                          : (currentStory
                                                                    .author
                                                                    ?.displayName ??
                                                                'Author'),
                                                      style: TextStyle(
                                                        color: theme
                                                            .colorScheme
                                                            .onSurface
                                                            .withValues(
                                                              alpha: 0.7,
                                                            ),
                                                        fontSize: 13,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  IconButton(
                                                    icon: Icon(
                                                      Icons.close_rounded,
                                                      color: theme
                                                          .colorScheme
                                                          .onSurface
                                                          .withValues(
                                                            alpha: 0.6,
                                                          ),
                                                      size: 24,
                                                    ),
                                                    onPressed: () {
                                                      ref
                                                          .read(
                                                            audioPlayerProvider
                                                                .notifier,
                                                          )
                                                          .closePlayer();
                                                    },
                                                  ),
                                                  IconButton(
                                                    icon: Icon(
                                                      Icons
                                                          .keyboard_arrow_down_rounded,
                                                      color: theme
                                                          .colorScheme
                                                          .onSurface
                                                          .withValues(
                                                            alpha: 0.6,
                                                          ),
                                                      size: 28,
                                                    ),
                                                    onPressed: () {
                                                      ref
                                                          .read(
                                                            miniPlayerExpandedProvider
                                                                .notifier,
                                                          )
                                                          .setExpanded(false);
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        ExpandedTTSBar(story: currentStory),
                                      ],
                                    ),
                                  ),
                                ] else ...[
                                  // Collapsed View (Mini Player)
                                  SizedBox(
                                    height: 64,
                                    child: Stack(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                          ),
                                          child: Row(
                                            children: [
                                              // Animated Equalizer / Icon
                                              Container(
                                                margin: const EdgeInsets.only(
                                                  right: 12,
                                                ),
                                                width: 24,
                                                height: 24,
                                                child: audioState.isPlaying
                                                    ? AudioVisualizer(
                                                        isPlaying: audioState
                                                            .isPlaying,
                                                        color: theme
                                                            .colorScheme
                                                            .primary,
                                                        barCount: 4,
                                                      )
                                                    : Icon(
                                                        Icons
                                                            .music_note_rounded,
                                                        color: theme
                                                            .colorScheme
                                                            .primary,
                                                        size: 20,
                                                      ),
                                              ),
                                              // Middle Text
                                              Expanded(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      currentStory
                                                              .heading
                                                              .isNotEmpty
                                                          ? currentStory.heading
                                                          : 'Audio Story',
                                                      style: TextStyle(
                                                        color: theme
                                                            .colorScheme
                                                            .onSurface,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 15,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    Text(
                                                      (!currentStory
                                                              .displayAuthorName)
                                                          ? 'Anonymous'
                                                          : (currentStory
                                                                    .author
                                                                    ?.displayName ??
                                                                'Author'),
                                                      style: TextStyle(
                                                        color: theme
                                                            .colorScheme
                                                            .onSurface
                                                            .withValues(
                                                              alpha: 0.7,
                                                            ),
                                                        fontSize: 13,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              // Right actions
                                              InkWell(
                                                onTap: () {
                                                  ref
                                                      .read(
                                                        audioPlayerProvider
                                                            .notifier,
                                                      )
                                                      .togglePlayPause(
                                                        currentStory,
                                                      );
                                                },
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    4.0,
                                                  ),
                                                  child: Icon(
                                                    audioState.isPlaying
                                                        ? Icons.pause_rounded
                                                        : Icons
                                                              .play_arrow_rounded,
                                                    color: theme
                                                        .colorScheme
                                                        .onSurface,
                                                    size: 28,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Progress Indicator at the bottom edge
                                        Positioned(
                                          bottom: 0,
                                          left: 0,
                                          right: 0,
                                          child: LinearProgressIndicator(
                                            value: audioState.progress.isNaN
                                                ? 0.0
                                                : audioState.progress.clamp(
                                                    0.0,
                                                    1.0,
                                                  ),
                                            backgroundColor: Colors.transparent,
                                            color: theme.colorScheme.primary,
                                            minHeight: 2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../../features/milestone/presentation/widgets/comments_thread.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:healing_milestones/core/models/story_model.dart';
import 'package:healing_milestones/core/router/app_routes.dart';
import 'package:healing_milestones/features/auth/data/auth_provider.dart';
import 'package:healing_milestones/features/auth/data/repository_providers.dart';
import 'package:healing_milestones/features/posts/data/story_providers.dart';
import 'package:healing_milestones/shared/widgets/qr_share_preview.dart';

import 'package:healing_milestones/shared/widgets/reaction_picker.dart';

class InteractionSection extends HookConsumerWidget {
  final StoryModel story;
  final bool showLabels;
  final bool isVertical;

  const InteractionSection({
    Key? key,
    required this.story,
    this.showLabels = true,
    this.isVertical = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);

    // 1. Calculate initial accurate state from story object
    // 1. Calculate initial accurate state from story object
    final reactionCounts = <ReactionType, int>{};
    ReactionType? initialUserReaction;
    int initialTotalReactions = 0;

    for (final entry in story.reactionCounts.entries) {
      final type = ReactionType.values.firstWhere(
        (e) => e.name == entry.key,
        orElse: () => ReactionType.heart,
      );
      reactionCounts[type] = entry.value;
      initialTotalReactions += entry.value;
    }

    if (story.currentUserReaction != null && story.currentUserReaction!.isNotEmpty) {
      initialUserReaction = ReactionType.values.firstWhere(
        (e) => e.name == story.currentUserReaction,
        orElse: () => ReactionType.heart,
      );
    }

    // 2. Set up optimistic state
    final optimisticUserReaction = useState<ReactionType?>(initialUserReaction);
    final optimisticTotalReactions = useState<int>(initialTotalReactions);
    final optimisticReactionCounts = useState<Map<ReactionType, int>>(reactionCounts);

    // Sync state if story object changes from stream/refresh
    useEffect(() {
      optimisticUserReaction.value = initialUserReaction;
      optimisticTotalReactions.value = initialTotalReactions;
      optimisticReactionCounts.value = Map.from(reactionCounts);
      return null;
    }, [story.reactionCounts, story.currentUserReaction, initialUserReaction]);

    final initialIsBookmarked =
        user?.bookmarkedStories.contains(story.storyId) ?? false;
    final optimisticIsBookmarked = useState<bool>(initialIsBookmarked);

    useEffect(() {
      optimisticIsBookmarked.value = initialIsBookmarked;
      return null;
    }, [initialIsBookmarked]);

    final isBookmarked = optimisticIsBookmarked.value;
    
    // Vertical Layout (TikTok / Reels style)
    if (isVertical) {
      final iconShadows = [
        Shadow(color: Colors.black.withValues(alpha: 0.6), blurRadius: 8, offset: const Offset(0, 2))
      ];

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // REACT BUTTON
          _ActionButton(
            isVertical: true,
            icon: optimisticUserReaction.value != null
                ? Text(optimisticUserReaction.value!.emoji,
                    style: TextStyle(fontSize: 24, shadows: iconShadows))
                : Icon(Icons.favorite_border,
                    color: Colors.white, size: 24, shadows: iconShadows),
            label: '${optimisticTotalReactions.value}',
            labelColor: Colors.white,
            showLabel: optimisticTotalReactions.value > 0, // Show count directly below icon
            reserveLabelSpace: true, // Prevent layout shift when count goes from 0 to 1
            labelShadows: iconShadows,
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
              if (user == null) {
                context.push(AppRoutes.login);
                return;
              }
              final targetReaction = optimisticUserReaction.value?.name ??
                  ReactionType.heart.name;

              if (optimisticUserReaction.value != null) {
                final oldReaction = optimisticUserReaction.value!;
                optimisticUserReaction.value = null;
                optimisticTotalReactions.value =
                    (optimisticTotalReactions.value - 1).clamp(0, 999999);

                final newCounts = Map<ReactionType, int>.from(
                    optimisticReactionCounts.value);
                newCounts[oldReaction] = (newCounts[oldReaction] ?? 1) - 1;
                if (newCounts[oldReaction]! <= 0)
                  newCounts.remove(oldReaction);
                optimisticReactionCounts.value = newCounts;
              } else {
                optimisticUserReaction.value = ReactionType.heart;
                optimisticTotalReactions.value++;

                final newCounts = Map<ReactionType, int>.from(
                    optimisticReactionCounts.value);
                newCounts[ReactionType.heart] =
                    (newCounts[ReactionType.heart] ?? 0) + 1;
                optimisticReactionCounts.value = newCounts;
              }
              ref.read(storyRepositoryProvider).toggleReaction(
                  story.storyId, user.userId, targetReaction);
            },
            onLongPressStart: (details) {
              FocusManager.instance.primaryFocus?.unfocus();
              if (user == null) {
                context.push(AppRoutes.login);
                return;
              }
              Future.delayed(const Duration(milliseconds: 50), () {
                if (!context.mounted) return;
                showReactionPicker(context, details.globalPosition,
                    (reaction) {
                  final newCounts = Map<ReactionType, int>.from(
                      optimisticReactionCounts.value);

                  if (optimisticUserReaction.value == null) {
                    optimisticTotalReactions.value++;
                  } else {
                    final oldReaction = optimisticUserReaction.value!;
                    newCounts[oldReaction] =
                        (newCounts[oldReaction] ?? 1) - 1;
                    if (newCounts[oldReaction]! <= 0)
                      newCounts.remove(oldReaction);
                  }

                  optimisticUserReaction.value = reaction;
                  newCounts[reaction] = (newCounts[reaction] ?? 0) + 1;
                  optimisticReactionCounts.value = newCounts;

                  ref.read(storyRepositoryProvider).toggleReaction(
                      story.storyId, user.userId, reaction.name);
                });
              });
            },
          ),
          
          // COMMENT BUTTON
          _ActionButton(
            isVertical: true,
            icon: Icon(Icons.chat_bubble_outline_rounded, color: Colors.white, size: 24, shadows: iconShadows),
            label: '${story.commentCount}',
            labelColor: Colors.white,
            showLabel: story.commentCount > 0,
            reserveLabelSpace: true,
            labelShadows: iconShadows,
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
              showCommentsBottomSheet(context, story);
            },
          ),
          
          // SHARE BUTTON
          _ActionButton(
            isVertical: true,
            icon: Icon(Icons.share_outlined, color: Colors.white, size: 24, shadows: iconShadows),
            label: 'Share',
            labelColor: Colors.white,
            showLabel: showLabels,
            reserveLabelSpace: true, // Equalizes the gap between Share and Save
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
              showShareOptions(context, story.storyId);
            },
          ),
          
          // SAVE BUTTON
          _ActionButton(
            isVertical: true,
            icon: Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: isBookmarked ? theme.colorScheme.primary : Colors.white,
              size: 24,
              shadows: iconShadows,
            ),
            label: 'Save',
            labelColor: isBookmarked ? theme.colorScheme.primary : Colors.white,
            showLabel: showLabels,
            onTap: () async {
              FocusManager.instance.primaryFocus?.unfocus();
              if (user == null) {
                context.push(AppRoutes.login);
                return;
              }

              optimisticIsBookmarked.value = !isBookmarked;
              final updatedBookmarks = List<String>.from(user.bookmarkedStories);
              if (!isBookmarked) {
                updatedBookmarks.add(story.storyId);
              } else {
                updatedBookmarks.remove(story.storyId);
              }
              final updatedUser =
                  user.copyWith(bookmarkedStories: updatedBookmarks);
              await ref
                  .read(authProvider.notifier)
                  .updateProfile(updatedUser);
              await ref
                  .read(userRepositoryProvider)
                  .toggleBookmark(user.userId, story.storyId);

              if (!context.mounted) return;
              ref.invalidate(userStreamProvider(user.userId));
              ref.invalidate(bookmarkedStoriesProvider(user.userId));
            },
          ),
        ],
      );
    }

    // Horizontal Layout (Standard)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // SUMMARY ROW (LinkedIn style)
        if (optimisticTotalReactions.value > 0 || story.commentCount > 0)
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (optimisticReactionCounts.value.values
                    .any((count) => count > 0))
                  Wrap(
                    spacing: 6,
                    children: optimisticReactionCounts.value.entries
                        .where((entry) => entry.value > 0)
                        .map((entry) {
                      final hasReactedThis =
                          optimisticUserReaction.value == entry.key;
                      return GestureDetector(
                        onTap: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          if (user == null) {
                            context.push(AppRoutes.login);
                            return;
                          }
                          final targetReaction = entry.key;

                          if (hasReactedThis) {
                            optimisticUserReaction.value = null;
                            optimisticTotalReactions.value =
                                (optimisticTotalReactions.value - 1)
                                    .clamp(0, 999999);

                            final newCounts = Map<ReactionType, int>.from(
                                optimisticReactionCounts.value);
                            newCounts[targetReaction] =
                                (newCounts[targetReaction] ?? 1) - 1;
                            if (newCounts[targetReaction]! <= 0)
                              newCounts.remove(targetReaction);
                            optimisticReactionCounts.value = newCounts;
                          } else {
                            final newCounts = Map<ReactionType, int>.from(
                                optimisticReactionCounts.value);

                            if (optimisticUserReaction.value == null) {
                              optimisticTotalReactions.value++;
                            } else {
                              final oldReaction = optimisticUserReaction.value!;
                              newCounts[oldReaction] =
                                  (newCounts[oldReaction] ?? 1) - 1;
                              if (newCounts[oldReaction]! <= 0)
                                newCounts.remove(oldReaction);
                            }

                            optimisticUserReaction.value = targetReaction;
                            newCounts[targetReaction] =
                                (newCounts[targetReaction] ?? 0) + 1;
                            optimisticReactionCounts.value = newCounts;
                          }
                          ref.read(storyRepositoryProvider).toggleReaction(
                              story.storyId, user.userId, targetReaction.name);
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 0),
                          decoration: BoxDecoration(
                            color: hasReactedThis
                                ? theme.colorScheme.primary
                                    .withValues(alpha: 0.1)
                                : theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: hasReactedThis
                                  ? theme.colorScheme.primary
                                      .withValues(alpha: 0.5)
                                  : Colors.transparent,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(entry.key.emoji,
                                  style: const TextStyle(fontSize: 14)),
                              const SizedBox(width: 4),
                              Text(
                                '${entry.value}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: hasReactedThis
                                      ? theme.colorScheme.primary
                                      : theme.textTheme.bodySmall?.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  )
                else
                  const SizedBox.shrink(),
              ],
            ),
          )
        else
          const SizedBox(height: 16),

        // DIVIDER
        Divider(
            height: 1,
            thickness: .4,
            color: theme.colorScheme.primary.withValues(alpha: 0.4)),

        // ACTIONS ROW
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // SHARE BUTTON
              _ActionButton(
                icon: Icon(Icons.share_outlined,
                    color: theme.textTheme.bodySmall?.color, size: 20),
                label: 'Share',
                labelColor: theme.textTheme.bodySmall?.color,
                showLabel: showLabels,
                onTap: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  showShareOptions(context, story.storyId);
                },
              ),
              // COMMENT BUTTON
              _ActionButton(
                icon: Icon(Icons.chat_bubble_outline_rounded,
                    color: theme.textTheme.bodySmall?.color, size: 20),
                label: story.commentCount > 0 ? '${story.commentCount}' : 'Comment',
                labelColor: theme.textTheme.bodySmall?.color,
                showLabel: showLabels,
                onTap: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  showCommentsBottomSheet(context, story);
                },
              ),
              // REACT BUTTON
              _ActionButton(
                icon: optimisticUserReaction.value != null
                    ? Text(optimisticUserReaction.value!.emoji,
                        style: TextStyle(fontSize: showLabels ? 14 : 12))
                    : Icon(Icons.favorite_border,
                        color: theme.textTheme.bodySmall?.color, size: 20),
                label: optimisticUserReaction.value != null
                    ? optimisticUserReaction.value!.label
                    : 'React',
                labelColor: optimisticUserReaction.value != null
                    ? theme.colorScheme.primary
                    : theme.textTheme.bodySmall?.color,
                showLabel: showLabels,
                onTap: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  if (user == null) {
                    context.push(AppRoutes.login);
                    return;
                  }
                  final targetReaction = optimisticUserReaction.value?.name ??
                      ReactionType.heart.name;

                  if (optimisticUserReaction.value != null) {
                    final oldReaction = optimisticUserReaction.value!;
                    optimisticUserReaction.value = null;
                    optimisticTotalReactions.value =
                        (optimisticTotalReactions.value - 1).clamp(0, 999999);

                    final newCounts = Map<ReactionType, int>.from(
                        optimisticReactionCounts.value);
                    newCounts[oldReaction] = (newCounts[oldReaction] ?? 1) - 1;
                    if (newCounts[oldReaction]! <= 0)
                      newCounts.remove(oldReaction);
                    optimisticReactionCounts.value = newCounts;
                  } else {
                    optimisticUserReaction.value = ReactionType.heart;
                    optimisticTotalReactions.value++;

                    final newCounts = Map<ReactionType, int>.from(
                        optimisticReactionCounts.value);
                    newCounts[ReactionType.heart] =
                        (newCounts[ReactionType.heart] ?? 0) + 1;
                    optimisticReactionCounts.value = newCounts;
                  }
                  ref.read(storyRepositoryProvider).toggleReaction(
                      story.storyId, user.userId, targetReaction);
                },
                onLongPressStart: (details) {
                  FocusManager.instance.primaryFocus?.unfocus();
                  if (user == null) {
                    context.push(AppRoutes.login);
                    return;
                  }

                  // Delay showing the dialog slightly so that the unfocus has time to propagate
                  // and the dialog doesn't capture the text field as the "previously focused" node.
                  Future.delayed(const Duration(milliseconds: 50), () {
                    if (!context.mounted) return;
                    showReactionPicker(context, details.globalPosition,
                        (reaction) {
                      final newCounts = Map<ReactionType, int>.from(
                          optimisticReactionCounts.value);

                      if (optimisticUserReaction.value == null) {
                        optimisticTotalReactions.value++;
                      } else {
                        final oldReaction = optimisticUserReaction.value!;
                        newCounts[oldReaction] =
                            (newCounts[oldReaction] ?? 1) - 1;
                        if (newCounts[oldReaction]! <= 0)
                          newCounts.remove(oldReaction);
                      }

                      optimisticUserReaction.value = reaction;
                      newCounts[reaction] = (newCounts[reaction] ?? 0) + 1;
                      optimisticReactionCounts.value = newCounts;

                      ref.read(storyRepositoryProvider).toggleReaction(
                          story.storyId, user.userId, reaction.name);
                    });
                  });
                },
              ),

              // SAVE BUTTON
              _ActionButton(
                icon: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: isBookmarked
                      ? theme.colorScheme.primary
                      : theme.textTheme.bodySmall?.color,
                  size: 20,
                ),
                label: 'Save',
                labelColor: isBookmarked
                    ? theme.colorScheme.primary
                    : theme.textTheme.bodySmall?.color,
                showLabel: showLabels,
                onTap: () async {
                  FocusManager.instance.primaryFocus?.unfocus();
                  if (user == null) {
                    context.push(AppRoutes.login);
                    return;
                  }

                  // Optimistic update
                  optimisticIsBookmarked.value = !isBookmarked;

                  final updatedBookmarks =
                      List<String>.from(user.bookmarkedStories);
                  if (!isBookmarked) {
                    updatedBookmarks.add(story.storyId);
                  } else {
                    updatedBookmarks.remove(story.storyId);
                  }
                  final updatedUser =
                      user.copyWith(bookmarkedStories: updatedBookmarks);
                  await ref
                      .read(authProvider.notifier)
                      .updateProfile(updatedUser);

                  await ref
                      .read(userRepositoryProvider)
                      .toggleBookmark(user.userId, story.storyId);

                  if (!context.mounted) return;

                  // Force refresh user data
                  ref.invalidate(userStreamProvider(user.userId));
                  ref.invalidate(bookmarkedStoriesProvider(user.userId));
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final Widget icon;
  final String label;
  final Color? labelColor;
  final List<Shadow>? labelShadows;
  final VoidCallback onTap;
  final void Function(LongPressStartDetails)? onLongPressStart;
  final bool showLabel;
  final bool reserveLabelSpace;
  final bool isVertical;

  const _ActionButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.labelColor,
    this.labelShadows,
    required this.onTap,
    this.onLongPressStart,
    this.showLabel = true,
    this.reserveLabelSpace = false,
    this.isVertical = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPressStart: onLongPressStart,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: isVertical
            ? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0)
            : const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: isVertical
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  icon,
                  Visibility(
                    visible: showLabel,
                    maintainSize: reserveLabelSpace,
                    maintainAnimation: reserveLabelSpace,
                    maintainState: reserveLabelSpace,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          label,
                          style: TextStyle(
                            color: labelColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 13, // slightly larger for count readability
                            height: 1.0,
                            shadows: labelShadows,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  icon,
                  if (showLabel) ...[
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: TextStyle(
                        color: labelColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        height: 1.0,
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}

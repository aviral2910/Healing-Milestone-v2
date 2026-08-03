import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:healing_milestones/core/models/story_model.dart';
import 'package:healing_milestones/core/router/app_routes.dart';
import 'package:healing_milestones/features/auth/data/auth_provider.dart';
import 'package:healing_milestones/features/auth/data/repository_providers.dart';
import 'package:healing_milestones/features/posts/data/story_providers.dart';

import 'package:healing_milestones/shared/widgets/reaction_picker.dart';

class InteractionSection extends HookConsumerWidget {
  final StoryModel story;
  final bool showLabels;

  const InteractionSection({
    Key? key,
    required this.story,
    this.showLabels = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);

    // 1. Calculate initial accurate state from story object
    final uniqueUsers = <String>{};
    final reactionCounts = <ReactionType, int>{};
    ReactionType? initialUserReaction;

    for (final entry in story.reactions.entries) {
      final type = ReactionType.values.firstWhere(
        (e) => e.name == entry.key,
        orElse: () => ReactionType.heart,
      );
      reactionCounts[type] = (reactionCounts[type] ?? 0) + entry.value.length;
      uniqueUsers.addAll(entry.value);

      if (user != null && entry.value.contains(user.userId)) {
        initialUserReaction = type;
      }
    }

    if (story.likesList.isNotEmpty) {
      final newLegacyUsers =
          story.likesList.where((id) => !uniqueUsers.contains(id)).toList();
      if (newLegacyUsers.isNotEmpty) {
        reactionCounts[ReactionType.heart] =
            (reactionCounts[ReactionType.heart] ?? 0) + newLegacyUsers.length;
        uniqueUsers.addAll(newLegacyUsers);
      }
      if (user != null &&
          initialUserReaction == null &&
          story.likesList.contains(user.userId)) {
        initialUserReaction = ReactionType.heart;
      }
    }

    // 2. Set up optimistic state
    final initialTotalReactions = uniqueUsers.length;
    final optimisticUserReaction = useState<ReactionType?>(initialUserReaction);
    final optimisticTotalReactions = useState<int>(initialTotalReactions);
    final optimisticReactionCounts =
        useState<Map<ReactionType, int>>(reactionCounts);

    // Sync state if story object changes from stream/refresh
    useEffect(() {
      optimisticUserReaction.value = initialUserReaction;
      optimisticTotalReactions.value = initialTotalReactions;
      optimisticReactionCounts.value = Map.from(reactionCounts);
      return null;
    }, [story.reactions, story.likesList, initialUserReaction]);

    final isBookmarked =
        user?.bookmarkedStories.contains(story.storyId) ?? false;

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
          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // REACT BUTTON
              _ActionButton(
                icon: optimisticUserReaction.value != null
                    ? Text(optimisticUserReaction.value!.emoji,
                        style: const TextStyle(fontSize: 20))
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
                onTap: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  if (user == null) {
                    context.push(AppRoutes.login);
                    return;
                  }
                  ref
                      .read(userRepositoryProvider)
                      .toggleBookmark(user.userId, story.storyId);
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
  final VoidCallback onTap;
  final void Function(LongPressStartDetails)? onLongPressStart;
  final bool showLabel;

  const _ActionButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.labelColor,
    required this.onTap,
    this.onLongPressStart,
    this.showLabel = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPressStart: onLongPressStart,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
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
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

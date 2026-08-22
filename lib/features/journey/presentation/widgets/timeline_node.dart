import 'package:healing_milestones/features/posts/data/story_providers.dart';
import 'audio_player_widget.dart';
import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/healing_snackbar.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healing_milestones/features/journey/presentation/widgets/journey_comments_thread.dart';
import '../../data/models/journey_models.dart';
import '../../data/providers/journey_providers.dart';
import '../../data/providers/paginated_journey_milestones_provider.dart';
import 'package:intl/intl.dart';
import 'log_milestone_overlay.dart';

class TimelineNode extends ConsumerWidget {
  final JourneyMilestoneModel milestone;
  final bool isReversed;
  final bool isHistoricalClosure;

  const TimelineNode({
    super.key,
    required this.milestone,
    this.isReversed = false,
    this.isHistoricalClosure = false,
  });

  void _showReactionOverlay(
    BuildContext context,
    WidgetRef ref,
    Offset position,
  ) {
    HapticFeedback.selectionClick();
    final theme = Theme.of(context);
    final reactions = [
      {'icon': '❤️', 'label': 'love'},
      {'icon': '🙏', 'label': 'support'},
      {'icon': '💪', 'label': 'strength'},
      {'icon': '✨', 'label': 'spark'},
    ];

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.transparent,
      pageBuilder: (context, animation, secondaryAnimation) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                behavior: HitTestBehavior.opaque,
                child: Container(color: Colors.transparent),
              ),
            ),
            Positioned(
              left: (position.dx - 100).clamp(
                16.0,
                MediaQuery.of(context).size.width - 250.0,
              ),
              top: (position.dy - 80).clamp(
                kToolbarHeight,
                MediaQuery.of(context).size.height - 100.0,
              ),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.shadow.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: reactions.map((r) {
                      return GestureDetector(
                        onTap: () async {
                          Navigator.of(context).pop();
                          HapticFeedback.mediumImpact();
                          final scaffoldMessenger = ScaffoldMessenger.of(
                            context,
                          );
                          try {
                            await ref
                                .read(journeyRepositoryProvider)
                                .reactToMilestone(milestone.id, r['label']!);
                            if (milestone.journeyId != null) {
                              ref.invalidate(
                                paginatedJourneyMilestonesProvider(
                                  milestone.journeyId!,
                                ),
                              );
                              ref.invalidate(
                                paginatedJourneyMilestonesProvider(
                                  milestone.journeyId!,
                                  isPublic: true,
                                ),
                              );
                            }
                            ref.invalidate(recommendedMilestonesProvider);
                            ref.invalidate(followingMilestonesProvider);
                            ref.invalidate(myFloatingMilestonesProvider);
                            ref.invalidate(allCheckinsProvider);
                          } catch (e) {
                            scaffoldMessenger.showSnackBar(
                              SnackBar(
                                content: Text(e.toString()),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            r['icon']!,
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
            ),
            child: child,
          ),
        );
      },
    );
  }

  Color _getEmotionColor(BuildContext context, EmotionStatus status) {
    switch (status) {
      case EmotionStatus.proud:
        return Colors.amber;
      case EmotionStatus.hopeful:
        return Colors.orange;
      case EmotionStatus.anxious:
        return Colors.blue;
      case EmotionStatus.grieving:
        return Colors.deepPurple;
      case EmotionStatus.neutral:
      default:
        return Colors.grey;
    }
  }

  Widget _buildClosureCard(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0, right: 16.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.verified_rounded,
              color: theme.colorScheme.primary,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              'Journey Completed',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            if (milestone.content?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Text(
                milestone.content!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (milestone.audioUrl != null && milestone.audioUrl!.isNotEmpty)
              AudioPlayerWidget(audioUrl: milestone.audioUrl!),
            const SizedBox(height: 8),
            Text(
              DateFormat('MMM d').format(milestone.createdAt),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReopeningCard(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0, right: 16.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.energy_savings_leaf_rounded,
              color: theme.colorScheme.primary,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              'Journey Resumed',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            if (milestone.content?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Text(
                milestone.content!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (milestone.audioUrl != null && milestone.audioUrl!.isNotEmpty)
              AudioPlayerWidget(audioUrl: milestone.audioUrl!),
            const SizedBox(height: 8),
            Text(
              DateFormat('MMM d').format(milestone.createdAt),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStandardCard(
    BuildContext context,
    ThemeData theme,
    Color emotionColor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0, right: 16.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: emotionColor.withValues(alpha: 0.15),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: emotionColor.withValues(alpha: 0.04),
              blurRadius: 24,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: emotionColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    (milestone.professionalTag?.name ??
                            milestone.emotionStatus?.name ??
                            "UPDATE")
                        .toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: emotionColor,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  DateFormat('MMM d').format(milestone.createdAt),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (milestone.isMine)
                  Theme(
                    data: Theme.of(context).copyWith(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                    ),
                    child: Consumer(
                      builder: (context, ref, child) {
                        return PopupMenuButton<String>(
                          icon: Icon(
                            Icons.more_vert,
                            size: 16,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          padding: EdgeInsets.zero,
                          onSelected: (value) async {
                            if (value == 'edit') {
                              LogMilestoneOverlay.show(
                                context,
                                journeyId: milestone.journeyId,
                                milestone: milestone,
                              );
                            } else if (value == 'delete') {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete Check-In'),
                                  content: const Text(
                                    'Are you sure you want to delete this check-in?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text(
                                        'Delete',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                try {
                                  if (milestone.audioUrl != null &&
                                      milestone.audioUrl!.isNotEmpty) {
                                    try {
                                      await ref
                                          .read(storageRepositoryProvider)
                                          .deleteImageFromUrl(
                                            milestone.audioUrl!,
                                          );
                                    } catch (e) {
                                      debugPrint(
                                        'Failed to delete audio from R2: $e',
                                      );
                                    }
                                  }
                                  if (milestone.mediaUrl != null &&
                                      milestone.mediaUrl!.isNotEmpty) {
                                    try {
                                      await ref
                                          .read(storageRepositoryProvider)
                                          .deleteImageFromUrl(
                                            milestone.mediaUrl!,
                                          );
                                    } catch (e) {
                                      debugPrint(
                                        'Failed to delete media from R2: $e',
                                      );
                                    }
                                  }
                                  await ref
                                      .read(journeyRepositoryProvider)
                                      .deleteMilestone(milestone.id);
                                  if (milestone.journeyId != null) {
                                    ref.invalidate(
                                      paginatedJourneyMilestonesProvider(
                                        milestone.journeyId!,
                                      ),
                                    );
                                    ref.invalidate(
                                      paginatedJourneyMilestonesProvider(
                                        milestone.journeyId!,
                                        isPublic: true,
                                      ),
                                    );
                                    ref.invalidate(
                                      paginatedJourneyMilestonesProvider(
                                        milestone.journeyId!,
                                        isPublic: true,
                                      ),
                                    );
                                    ref.invalidate(
                                      paginatedJourneyMilestonesProvider(
                                        milestone.journeyId!,
                                        isPublic: true,
                                      ),
                                    );
                                  } else {
                                    ref.invalidate(
                                      myFloatingMilestonesProvider,
                                    );
                                  }
                                  ref.invalidate(recommendedMilestonesProvider);
                                  ref.invalidate(followingMilestonesProvider);
                                  ref.invalidate(myFloatingMilestonesProvider);
                                  ref.invalidate(allCheckinsProvider);
                                } catch (e) {
                                  if (context.mounted) {
                                    HealingSnackbar.showError(context, e);
                                  }
                                }
                              }
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (milestone.content != null)
              Text(
                milestone.content!,
                style: theme.textTheme.bodyLarge?.copyWith(
                  height: 1.5,
                  color: theme.colorScheme.onSurface,
                ),
              ),

            if (milestone.audioUrl != null && milestone.audioUrl!.isNotEmpty)
              AudioPlayerWidget(audioUrl: milestone.audioUrl!),

            if (milestone.content != null ||
                (milestone.audioUrl != null && milestone.audioUrl!.isNotEmpty))
              const SizedBox(height: 16),
            Row(
              children: [
                if (milestone.reactionCounts.isNotEmpty)
                  ...milestone.reactionCounts.entries
                      .where((e) => e.value > 0)
                      .map((entry) {
                        String emoji = '❤️';
                        switch (entry.key) {
                          case 'spark':
                            emoji = '✨';
                            break;
                          case 'strength':
                            emoji = '💪';
                            break;
                          case 'love':
                            emoji = '❤️';
                            break;
                          case 'support':
                            emoji = '🙏';
                            break;
                        }
                        return Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.2,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(emoji, style: const TextStyle(fontSize: 12)),
                              const SizedBox(width: 4),
                              Text(
                                '${entry.value}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                if (milestone.reactionCounts.isEmpty &&
                    milestone.reactionCount > 0)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.favorite_rounded,
                          size: 12,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${milestone.reactionCount}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                const Spacer(),
              ],
            ),
            SizedBox(height: 8),
            Divider(
              // height: 0,
              thickness: .5,
              color: theme.colorScheme.primary.withValues(alpha: .4),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (milestone.areCommentsEnabled) ...[
                  GestureDetector(
                    onTap: () {
                      showCommentsBottomSheet(context, milestone);
                      // from story comments, but it takes a StoryModel.
                      // Wait! The prompt says "if user enable it while creating it .and later to user can disable that tooo"
                      // We need to implement a bottom sheet for Milestone Comments.
                      // We can just show a placeholder print for now or navigate.
                      // Actually, let's leave it as a comment for now or show a coming soon snackbar.
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.dividerColor.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 16,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          if (milestone.commentCount > 0) ...[
                            const SizedBox(width: 6),
                            Text(
                              '${milestone.commentCount}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
                Consumer(
                  builder: (context, ref, child) {
                    String reactEmoji = '♡';
                    Color reactColor = theme.colorScheme.onSurfaceVariant;
                    bool isReacted = milestone.userReaction != null;
                    if (isReacted) {
                      switch (milestone.userReaction) {
                        case 'spark':
                          reactEmoji = '✨';
                          break;
                        case 'strength':
                          reactEmoji = '💪';
                          break;
                        case 'love':
                          reactEmoji = '❤️';
                          break;
                        case 'support':
                          reactEmoji = '🙏';
                          break;
                        default:
                          reactEmoji = '❤️';
                      }
                      reactColor = theme.colorScheme.primary;
                    }

                    return GestureDetector(
                      onTap: () async {
                        final scaffoldMessenger = ScaffoldMessenger.of(context);
                        HapticFeedback.selectionClick();
                        try {
                          if (isReacted) {
                            await ref
                                .read(journeyRepositoryProvider)
                                .removeReaction(milestone.id);
                          } else {
                            await ref
                                .read(journeyRepositoryProvider)
                                .reactToMilestone(milestone.id, 'love');
                          }
                          if (milestone.journeyId != null) {
                            ref.invalidate(
                              paginatedJourneyMilestonesProvider(
                                milestone.journeyId!,
                              ),
                            );
                            ref.invalidate(
                              paginatedJourneyMilestonesProvider(
                                milestone.journeyId!,
                                isPublic: true,
                              ),
                            );
                          }
                          ref.invalidate(recommendedMilestonesProvider);
                          ref.invalidate(followingMilestonesProvider);
                          ref.invalidate(myFloatingMilestonesProvider);
                          ref.invalidate(allCheckinsProvider);
                        } catch (e) {
                          scaffoldMessenger.showSnackBar(
                            const SnackBar(
                              content: Text('Failed to update reaction'),
                            ),
                          );
                        }
                      },
                      onLongPressStart: (details) => _showReactionOverlay(
                        context,
                        ref,
                        details.globalPosition,
                      ),
                      behavior: HitTestBehavior.opaque,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isReacted
                              ? reactColor.withValues(alpha: 0.08)
                              : theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isReacted
                                ? reactColor.withValues(alpha: 0.4)
                                : theme.dividerColor.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            isReacted
                                ? Text(
                                    reactEmoji,
                                    style: const TextStyle(fontSize: 12),
                                  )
                                : Icon(
                                    Icons.favorite_border_rounded,
                                    size: 16,
                                    color: reactColor,
                                  ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final emotionColor = _getEmotionColor(
      context,
      milestone.emotionStatus ?? EmotionStatus.neutral,
    );

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline Line and Dot Column
          SizedBox(
            width: 40,
            child: CustomPaint(
              painter: _TimelinePainter(
                position: milestone.timelinePosition,
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                dotColor: emotionColor,
                isReversed: isReversed,
              ),
            ),
          ),
          // Content Card
          Expanded(
            child: () {
              if (milestone.isReopening) {
                return _buildReopeningCard(context, theme);
              } else if (milestone.isClosure && !isHistoricalClosure) {
                return _buildClosureCard(context, theme);
              }
              return _buildStandardCard(context, theme, emotionColor);
            }(),
          ),
        ],
      ),
    );
  }
}

class _TimelinePainter extends CustomPainter {
  final TimelinePosition position;
  final Color color;
  final Color dotColor;
  final bool isReversed;

  _TimelinePainter({
    required this.position,
    required this.color,
    required this.dotColor,
    required this.isReversed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;

    final glowPaint = Paint()
      ..color = dotColor.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    final centerX = size.width / 2;
    // Dot is placed 24 pixels from the top of this widget
    final dotY = 24.0;

    // Draw the dot and glow
    canvas.drawCircle(Offset(centerX, dotY), 12, glowPaint);
    canvas.drawCircle(Offset(centerX, dotY), 5, dotPaint);

    // Draw lines based on position and reversal
    bool drawTop = false;
    bool drawBottom = false;

    switch (position) {
      case TimelinePosition.standalone:
        break;
      case TimelinePosition.start:
        drawTop = isReversed;
        drawBottom = !isReversed;
        break;
      case TimelinePosition.middle:
        drawTop = true;
        drawBottom = true;
        break;
      case TimelinePosition.end:
        drawTop = !isReversed;
        drawBottom = isReversed;
        break;
    }

    if (drawTop) {
      canvas.drawLine(Offset(centerX, 0), Offset(centerX, dotY - 14), paint);
    }
    if (drawBottom) {
      canvas.drawLine(
        Offset(centerX, dotY + 14),
        Offset(centerX, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TimelinePainter oldDelegate) {
    return oldDelegate.position != position ||
        oldDelegate.color != color ||
        oldDelegate.dotColor != dotColor ||
        oldDelegate.isReversed != isReversed;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/journey_models.dart';
import '../../data/providers/journey_providers.dart';
import 'package:intl/intl.dart';
import 'log_milestone_overlay.dart';

class TimelineNode extends ConsumerWidget {
  final JourneyMilestoneModel milestone;
  final bool isReversed;

  const TimelineNode({
    super.key, 
    required this.milestone,
    this.isReversed = false,
  });

  Color _getEmotionColor(BuildContext context, EmotionStatus status) {
    switch (status) {
      case EmotionStatus.proud: return Colors.amber;
      case EmotionStatus.hopeful: return Colors.orange;
      case EmotionStatus.anxious: return Colors.blue;
      case EmotionStatus.grieving: return Colors.deepPurple;
      case EmotionStatus.neutral:
      default: return Colors.grey;
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
            Icon(Icons.verified_rounded, color: theme.colorScheme.primary, size: 32),
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
            Icon(Icons.energy_savings_leaf_rounded, color: theme.colorScheme.primary, size: 32),
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

  Widget _buildStandardCard(BuildContext context, ThemeData theme, Color emotionColor) {
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: emotionColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    milestone.emotionStatus.name.toUpperCase(),
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
                Theme(
                  data: Theme.of(context).copyWith(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                  ),
                  child: Consumer(
                    builder: (context, ref, child) {
                      return PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert, size: 16, color: theme.colorScheme.onSurfaceVariant),
                        padding: EdgeInsets.zero,
                        onSelected: (value) async {
                          if (value == 'edit') {
                            LogMilestoneOverlay.show(context, journeyId: milestone.journeyId, milestone: milestone);
                          } else if (value == 'delete') {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Check-In'),
                                content: const Text('Are you sure you want to delete this check-in?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );
                            
                            if (confirm == true) {
                              try {
                                await ref.read(journeyRepositoryProvider).deleteMilestone(milestone.id);
                                if (milestone.journeyId != null) {
                                  ref.invalidate(journeyMilestonesProvider(milestone.journeyId!));
                                } else {
                                  ref.invalidate(myFloatingMilestonesProvider);
                                }
                                ref.invalidate(togetherFeedProvider);
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Failed to delete check-in: $e')),
                                  );
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
                            child: Text('Delete', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      );
                    }
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
          ],
        ),
      ),
    );
  }
@override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final emotionColor = _getEmotionColor(context, milestone.emotionStatus);

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
              } else if (milestone.isClosure) {
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
      canvas.drawLine(Offset(centerX, dotY + 14), Offset(centerX, size.height), paint);
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

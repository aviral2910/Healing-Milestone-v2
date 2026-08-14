import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/journey_models.dart';
import '../../../auth/data/auth_provider.dart';
import '../../data/providers/journey_providers.dart';
import '../screens/together_feed_screen.dart';
import 'public_journey_detail_overlay.dart';

class TogetherFeedCard extends ConsumerStatefulWidget {
  final JourneyMilestoneModel milestone;
  final int index;

  const TogetherFeedCard({Key? key, required this.milestone, this.index = 0})
    : super(key: key);

  @override
  ConsumerState<TogetherFeedCard> createState() => _TogetherFeedCardState();
}

class _TogetherFeedCardState extends ConsumerState<TogetherFeedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Color _getEmotionColor() {
    switch (widget.milestone.emotionStatus) {
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

  void _showReactionOverlay(BuildContext context) {
    HapticFeedback.heavyImpact();
    final container = ProviderScope.containerOf(context);

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return _ReactionOverlay(
          milestoneId: widget.milestone.id,
          currentReaction: widget.milestone.userReaction,
          container: container,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(0, 0.05),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final glowColor = _getEmotionColor();

    final bool isMyAnonymousJourney =
        widget.milestone.visibility == MilestoneVisibility.anonymous &&
        widget.milestone.isMine;

    final String displayAuthor =
        widget.milestone.visibility == MilestoneVisibility.anonymous
        ? (isMyAnonymousJourney ? 'Anonymous (You)' : 'Anonymous')
        : (widget.milestone.authorName ?? 'Anonymous');

    final Map<String, String> emojiMap = {
      'spark': '✨',
      'strength': '💪',
      'love': '❤️',
      'support': '🙏',
    };

    return GestureDetector(
      onTapDown: (_) => _animController.forward(),
      onTapUp: (_) => _animController.reverse(),
      onTapCancel: () => _animController.reverse(),
      onTap: () {
        _animController.reverse();
        if (widget.milestone.journeyId != null &&
            widget.milestone.journeyTitle != null) {
          PublicJourneyDetailOverlay.show(
            context,
            journeyId: widget.milestone.journeyId!,
            title: widget.milestone.journeyTitle!,
            category: widget.milestone.journeyCategory,
            authorName: widget.milestone.authorName,
            authorAvatar: widget.milestone.authorAvatar,
            isMine: widget.milestone.isMine,
            visibility: widget.milestone.visibility,
          );
        }
      },
      onLongPress: () {
        _animController.reverse();
        _showReactionOverlay(context);
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) =>
            Transform.scale(scale: _scaleAnimation.value, child: child),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: theme.dividerColor.withValues(alpha: 0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: glowColor.withValues(alpha: 0.05),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      glowColor.withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header (Avatar + Name)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isMyAnonymousJourney
                                ? theme.colorScheme.primary.withValues(
                                    alpha: 0.2,
                                  )
                                : theme.colorScheme.surface.withValues(
                                    alpha: 0.5,
                                  ),
                            border: Border.all(
                              color: isMyAnonymousJourney
                                  ? theme.colorScheme.primary
                                  : glowColor.withValues(alpha: 0.3),
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: isMyAnonymousJourney
                                ? theme.colorScheme.primary.withValues(
                                    alpha: 0.1,
                                  )
                                : theme.colorScheme.surface,
                            backgroundImage:
                                widget.milestone.authorAvatar != null &&
                                    widget.milestone.visibility ==
                                        MilestoneVisibility.public
                                ? NetworkImage(widget.milestone.authorAvatar!)
                                : null,
                            child:
                                (widget.milestone.authorAvatar == null ||
                                    widget.milestone.visibility ==
                                        MilestoneVisibility.anonymous)
                                ? Icon(
                                    widget.milestone.visibility ==
                                            MilestoneVisibility.anonymous
                                        ? Icons.visibility_off_rounded
                                        : Icons.person_rounded,
                                    color: isMyAnonymousJourney
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.onSurfaceVariant,
                                    size: 18,
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      displayAuthor,
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: -0.3,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Emotion Dot
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: glowColor,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: glowColor.withValues(
                                            alpha: 0.6,
                                          ),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              // Subtitle
                              RichText(
                                text: TextSpan(
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant
                                        .withValues(alpha: 0.8),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: _getTimeAgo(
                                        widget.milestone.createdAt,
                                      ),
                                    ),
                                    if (widget.milestone.journeyTitle !=
                                        null) ...[
                                      const TextSpan(text: ' • in '),
                                      TextSpan(
                                        text: widget.milestone.journeyTitle,
                                        style: TextStyle(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Content
                    if (widget.milestone.content != null)
                      Text(
                        widget.milestone.content!,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          height: 1.5,
                          fontSize: 16,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.9,
                          ),
                        ),
                      ),

                    const SizedBox(height: 20),

                    // Action Bar
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Reaction Summary
                          Expanded(
                            child: widget.milestone.reactionCounts.isNotEmpty
                                ? Wrap(
                                    spacing: 8,
                                    children: widget.milestone.reactionCounts.entries.map((entry) {
                                      if (entry.value <= 0 || !emojiMap.containsKey(entry.key)) return const SizedBox.shrink();
                                      final isMyReaction = widget.milestone.userReaction == entry.key;
                                      return GestureDetector(
                                        onTap: () async {
                                          final scaffoldMessenger = ScaffoldMessenger.of(context);
                                          final container = ProviderScope.containerOf(context);
                                          HapticFeedback.selectionClick();
                                          try {
                                            if (isMyReaction) {
                                              await container.read(journeyRepositoryProvider).removeReaction(widget.milestone.id);
                                            } else {
                                              await container.read(journeyRepositoryProvider).reactToMilestone(widget.milestone.id, entry.key);
                                            }
                                            container.invalidate(togetherFeedProvider);
                                          } catch (e) {
                                            scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Failed to update reaction')));
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: isMyReaction ? theme.colorScheme.primary.withValues(alpha: 0.1) : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: isMyReaction ? theme.colorScheme.primary.withValues(alpha: 0.3) : Colors.transparent,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(emojiMap[entry.key]!, style: const TextStyle(fontSize: 14)),
                                              const SizedBox(width: 4),
                                              Text(
                                                entry.value.toString(),
                                                style: theme.textTheme.labelMedium?.copyWith(
                                                  color: isMyReaction ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  )
                                : const SizedBox.shrink(),
                          ),

                          // React Button
                          GestureDetector(
                            onTap: () async {
                              final scaffoldMessenger = ScaffoldMessenger.of(context);
                              final container = ProviderScope.containerOf(context);
                              HapticFeedback.selectionClick();
                              try {
                                if (widget.milestone.userReaction != null) {
                                  await container.read(journeyRepositoryProvider).removeReaction(widget.milestone.id);
                                } else {
                                  await container.read(journeyRepositoryProvider).reactToMilestone(widget.milestone.id, 'spark');
                                }
                                container.invalidate(togetherFeedProvider);
                              } catch (e) {
                                scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Failed to update reaction')));
                              }
                            },
                            onLongPress: () => _showReactionOverlay(context),
                            behavior: HitTestBehavior.opaque,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 12.0, right: 8.0, top: 4.0, bottom: 4.0),
                              child: widget.milestone.userReaction != null && emojiMap.containsKey(widget.milestone.userReaction)
                                  ? Text(emojiMap[widget.milestone.userReaction]!, style: const TextStyle(fontSize: 22))
                                  : Icon(Icons.favorite_border_rounded, size: 24, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}

class _ReactionOverlay extends StatelessWidget {
  final String milestoneId;
  final String? currentReaction;
  final ProviderContainer container;

  const _ReactionOverlay({
    Key? key,
    required this.milestoneId,
    required this.container,
    this.currentReaction,
  }) : super(key: key);

  Widget _buildReactionOption(
    BuildContext context,
    String emoji,
    String label,
    Color color,
    String typeValue,
  ) {
    final theme = Theme.of(context);
    final isSelected = currentReaction == typeValue;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          final scaffoldMessenger = ScaffoldMessenger.of(context);
          HapticFeedback.selectionClick();
          Navigator.pop(context);

          try {
            if (isSelected) {
              await container
                  .read(journeyRepositoryProvider)
                  .removeReaction(milestoneId);
            } else {
              await container
                  .read(journeyRepositoryProvider)
                  .reactToMilestone(milestoneId, typeValue);
            }
            // Invalidate the public milestones feed to trigger a refresh
            container.invalidate(togetherFeedProvider);
          } catch (e) {
            scaffoldMessenger.showSnackBar(
              const SnackBar(content: Text('Failed to send reaction')),
            );
          }
        },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.2)
                : theme.colorScheme.surface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected ? color : color.withValues(alpha: 0.2),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 40)),
              const SizedBox(height: 12),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Glassmorphism background
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              color: (isDark ? Colors.black : Colors.white).withValues(
                alpha: 0.5,
              ),
            ),
          ),

          // Tap to dismiss
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              behavior: HitTestBehavior.opaque,
              child: Container(),
            ),
          ),

          // Center content
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Send a Spark',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Let them know you are here with them.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 48),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: _buildReactionOption(
                          context,
                          '✨',
                          'Spark',
                          theme.colorScheme.primary,
                          'spark',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildReactionOption(
                          context,
                          '💪',
                          'Strength',
                          theme.colorScheme.secondary,
                          'strength',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildReactionOption(
                          context,
                          '❤️',
                          'Love',
                          theme.colorScheme.tertiary,
                          'love',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildReactionOption(
                          context,
                          '🙏',
                          'Support',
                          Color.lerp(
                                theme.colorScheme.primary,
                                theme.colorScheme.secondary,
                                0.5,
                              ) ??
                              theme.colorScheme.primary,
                          'support',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

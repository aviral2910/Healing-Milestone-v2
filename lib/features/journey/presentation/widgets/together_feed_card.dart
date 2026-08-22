import 'audio_player_widget.dart';
import 'audio_player_widget.dart';
import '../screens/journey_detail_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/healing_snackbar.dart';
import 'package:healing_milestones/shared/widgets/app_avatar.dart';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/journey_models.dart';
import 'journey_comments_thread.dart';
import '../../data/providers/journey_providers.dart';
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

  void _showReactionOverlay(BuildContext context, Offset position) {
    HapticFeedback.selectionClick();
    final theme = Theme.of(context);
    final reactions = [
      {'icon': '❤️', 'label': 'love'},
      {'icon': '🙏', 'label': 'support'},
      {'icon': '💪', 'label': 'strength'},
      {'icon': '✨', 'label': 'spark'},
    ];
    final container = ProviderScope.containerOf(context);

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
                            await container
                                .read(journeyRepositoryProvider)
                                .reactToMilestone(
                                  widget.milestone.id,
                                  r['label']!,
                                );
                            container.invalidate(recommendedMilestonesProvider);
                            container.invalidate(followingMilestonesProvider);
                            container.invalidate(myFloatingMilestonesProvider);
                            container.invalidate(allCheckinsProvider);
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isDoctor =
        widget.milestone.authorRole == 'healthcareProfessional' ||
        (widget.milestone.authorRole?.toLowerCase().contains('organi') ??
            false);

    // Map emotion to color for the tiny badge
    Color emotionColor;
    if (isDoctor) {
      emotionColor = theme.colorScheme.primary;
    } else {
      switch (widget.milestone.emotionStatus) {
        case EmotionStatus.proud:
          emotionColor = Colors.orange;
          break;
        case EmotionStatus.hopeful:
          emotionColor = Colors.green;
          break;
        case EmotionStatus.anxious:
          emotionColor = Colors.purple;
          break;
        case EmotionStatus.grieving:
          emotionColor = Colors.blueGrey;
          break;
        case EmotionStatus.neutral:
        default:
          emotionColor = Colors.grey;
          break;
      }
    }

    final bool isClosure = widget.milestone.isClosure;
    final bool isReopening = widget.milestone.isReopening;

    final bool isMyAnonymousJourney =
        widget.milestone.visibility == MilestoneVisibility.anonymous &&
        widget.milestone.isMine;

    final String displayAuthor =
        widget.milestone.visibility == MilestoneVisibility.anonymous
        ? (isMyAnonymousJourney ? 'Anonymous (You)' : 'Anonymous')
        : (widget.milestone.authorName ?? 'Anonymous');

    // The "Miracle": Staggered Slide-In Animation based on the item index
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(
        milliseconds: 300 + (widget.index.clamp(0, 10) * 50),
      ), // Staggered delay
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)), // Soft slide up
          child: Opacity(opacity: value, child: child),
        );
      },
      child: GestureDetector(
        onTapDown: (_) {
          HapticFeedback.selectionClick(); // Tactile miracle
          _animController.forward();
        },
        onTapUp: (_) => _animController.reverse(),
        onTapCancel: () => _animController.reverse(),
        onTap: () {
          _animController.reverse();
          if (widget.milestone.journeyId != null &&
              widget.milestone.journeyTitle != null) {
            if (widget.milestone.authorUid != null &&
                widget.milestone.authorUid ==
                    FirebaseAuth.instance.currentUser?.uid) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => JourneyDetailScreen(
                    journeyId: widget.milestone.journeyId!,
                    title: widget.milestone.journeyTitle ?? 'Journey',
                    category: widget.milestone.journeyCategory,
                    visibility: widget.milestone.visibility,
                  ),
                ),
              );
            } else {
              PublicJourneyDetailOverlay.show(
                context,
                journeyId: widget.milestone.journeyId!,
                title: widget.milestone.journeyTitle ?? 'Journey',
                category: widget.milestone.journeyCategory,
                authorName: widget.milestone.authorName,
                authorAvatar: widget.milestone.authorAvatar,
                authorId: widget.milestone.authorUid ?? widget.milestone.userId,
                isMine: widget.milestone.isMine,
                visibility: widget.milestone.visibility,
                initialIsFollowing: widget.milestone.isFollowing,
              );
            }
          }
        },
        onLongPressStart: (details) {
          _animController.reverse();
          _showReactionOverlay(context, details.globalPosition);
        },
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) =>
              Transform.scale(scale: _scaleAnimation.value, child: child),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isClosure
                  ? null
                  : const Color(0xFF141414).withValues(alpha: 0.8),
              gradient: isClosure
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.primary.withValues(alpha: 0.1),
                        const Color(0xFF141414),
                        const Color(0xFF141414),
                      ],
                      stops: const [0.0, 0.4, 1.0],
                    )
                  : null,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isClosure
                    ? theme.colorScheme.primary.withValues(alpha: 0.6)
                    : theme.colorScheme.primary.withValues(alpha: 0.2),
                width: isClosure ? 1 : .5,
              ),
              boxShadow: [
                BoxShadow(
                  color: isClosure
                      ? theme.colorScheme.primary.withValues(alpha: 0.15)
                      : theme.colorScheme.primary.withValues(alpha: 0.02),
                  blurRadius: isClosure ? 24 : 12,
                  spreadRadius: isClosure ? -5 : 0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- 1. HEADER ROW (Avatar + Info) ---
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppAvatar(
                      imageUrl: widget.milestone.authorAvatar,
                      radius: 17,
                      role: widget.milestone.authorRole,
                      isAnonymous:
                          widget.milestone.visibility ==
                          MilestoneVisibility.anonymous,
                      showRing: true,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  displayAuthor,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (widget.milestone.authorIsVerified) ...[
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.verified,
                                  color: theme.colorScheme.primary,
                                  size: 14,
                                ),
                              ],
                            ],
                          ),
                          if (widget.milestone.authorTitle != null &&
                              widget.milestone.authorTitle!.isNotEmpty) ...[
                            const SizedBox(height: 1),
                            Text(
                              widget.milestone.authorTitle!,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                          ] else ...[
                            const SizedBox(height: 2),
                          ],
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                _getTimeAgo(widget.milestone.createdAt),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              if (widget.milestone.journeyTitle != null &&
                                  !isClosure) ...[
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: theme.colorScheme.primary
                                            .withValues(alpha: 0.2),
                                        width: 0.5,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.folder_rounded,
                                          size: 10,
                                          color: theme
                                              .colorScheme
                                              .primary, // Solid gold color
                                        ),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            widget.milestone.journeyTitle!,
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(
                                                  color: theme
                                                      .colorScheme
                                                      .primary, // Solid gold color
                                                  fontWeight: FontWeight.w800,
                                                  height: 1.1,
                                                ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Very small emotion badge opposite the name
                    Container(
                      margin: const EdgeInsets.only(
                        top: 2,
                      ), // Align visually with the name text height
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: isDoctor
                            ? theme.colorScheme.primary
                            : emotionColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: isDoctor
                            ? null
                            : Border.all(
                                color: emotionColor.withValues(alpha: 0.2),
                              ),
                      ),
                      child: Text(
                        (isDoctor && widget.milestone.professionalTag != null)
                            ? widget.milestone.professionalTag!.name
                                  .toUpperCase()
                            : (widget.milestone.emotionStatus?.name
                                      .toUpperCase() ??
                                  "UPDATE"),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isDoctor
                              ? theme.colorScheme.onPrimary
                              : emotionColor,
                          fontSize: 9, // Very small to match height of the name
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // --- 2. BODY CONTENT ---
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Event Markers inside the content (as drawn in sketch)
                    if (isClosure) ...[
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 24, top: 8),
                        child: Column(
                          children: [
                            Icon(
                              Icons.emoji_events_rounded,
                              color: theme.colorScheme.primary,
                              size: 48,
                              shadows: [
                                Shadow(
                                  color: theme.colorScheme.primary.withValues(
                                    alpha: 0.5,
                                  ),
                                  blurRadius: 16,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'JOURNEY COMPLETED',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2.0,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (widget.milestone.journeyTitle != null) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: theme.colorScheme.primary.withValues(
                                      alpha: 0.2,
                                    ),
                                    width: 1.0,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.folder_rounded,
                                      size: 14,
                                      color: theme.colorScheme.primary,
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        widget.milestone.journeyTitle!,
                                        style: theme.textTheme.labelMedium
                                            ?.copyWith(
                                              color: theme.colorScheme.primary,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 0.5,
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ] else if (isReopening) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.05,
                          ),
                          border: Border.all(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.2,
                            ),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.energy_savings_leaf_rounded,
                              color: theme.colorScheme.primary,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Journey Resumed',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    if (widget.milestone.content != null &&
                        widget.milestone.content!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          widget.milestone.content!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                            height: 1.5,
                          ),
                        ),
                      ),
                    if (widget.milestone.audioUrl != null &&
                        widget.milestone.audioUrl!.isNotEmpty)
                      AudioPlayerWidget(audioUrl: widget.milestone.audioUrl!),
                  ],
                ),

                const SizedBox(height: 16),

                // --- 3. FOOTER ROW ---
                Row(
                  children: [
                    // Multiple small reaction cards
                    ...widget.milestone.reactionCounts.entries
                        .where((e) => e.value > 0)
                        .map((entry) {
                          String emoji = '♡';
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
                              ), // Themic border
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  emoji,
                                  style: const TextStyle(fontSize: 12),
                                ),
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

                    // Fallback for legacy data if reactionCounts is empty but reactionCount > 0
                    if (widget.milestone.reactionCounts.isEmpty &&
                        widget.milestone.reactionCount > 0)
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
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.2,
                            ),
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
                              '${widget.milestone.reactionCount}',
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
                // React Button (Dynamic based on userReaction)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (widget.milestone.areCommentsEnabled) ...[
                      GestureDetector(
                        onTap: () {
                          showCommentsBottomSheet(context, widget.milestone);
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
                              if (widget.milestone.commentCount > 0) ...[
                                const SizedBox(width: 6),
                                Text(
                                  '${widget.milestone.commentCount}',
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
                    Builder(
                      builder: (context) {
                        String reactEmoji = '♡';
                        String reactLabel = 'React';
                        Color reactColor = theme.colorScheme.onSurfaceVariant;
                        bool isReacted = widget.milestone.userReaction != null;

                        if (isReacted) {
                          switch (widget.milestone.userReaction) {
                            case 'spark':
                              reactEmoji = '✨';
                              reactLabel = 'Spark';
                              break;
                            case 'strength':
                              reactEmoji = '💪';
                              reactLabel = 'Strength';
                              break;
                            case 'love':
                              reactEmoji = '❤️';
                              reactLabel = 'Love';
                              break;
                            case 'support':
                              reactEmoji = '🙏';
                              reactLabel = 'Support';
                              break;
                            default:
                              reactEmoji = '❤️';
                              reactLabel = 'Reacted';
                          }
                          reactColor = theme
                              .colorScheme
                              .primary; // Golden primary color when reacted
                        }

                        return GestureDetector(
                          onTap: () async {
                            final scaffoldMessenger = ScaffoldMessenger.of(
                              context,
                            );
                            final container = ProviderScope.containerOf(
                              context,
                            );
                            HapticFeedback.selectionClick();
                            try {
                              if (isReacted) {
                                await container
                                    .read(journeyRepositoryProvider)
                                    .removeReaction(widget.milestone.id);
                              } else {
                                await container
                                    .read(journeyRepositoryProvider)
                                    .reactToMilestone(
                                      widget.milestone.id,
                                      'love',
                                    ); // Default quick-react
                              }
                              container.invalidate(recommendedMilestonesProvider);
                              container.invalidate(followingMilestonesProvider);
                              container.invalidate(myFloatingMilestonesProvider);
                              container.invalidate(allCheckinsProvider);
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
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return '${diff.inDays}d';
    if (diff.inHours > 0) return '${diff.inHours}h';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m';
    return 'Now';
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/journey_models.dart';
import '../../data/providers/journey_providers.dart';

class LogMilestoneOverlay extends StatefulWidget {
  final String? initialJourneyId;
  final JourneyMilestoneModel? initialMilestone;

  const LogMilestoneOverlay({
    Key? key,
    this.initialJourneyId,
    this.initialMilestone,
  }) : super(key: key);

  static Future<void> show(
    BuildContext context, {
    String? journeyId,
    JourneyMilestoneModel? milestone,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.transparent, // We handle color in the widget
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return LogMilestoneOverlay(
          initialJourneyId: journeyId,
          initialMilestone: milestone,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ),
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
  State<LogMilestoneOverlay> createState() => _LogMilestoneOverlayState();
}

class _LogMilestoneOverlayState extends State<LogMilestoneOverlay> {
  EmotionStatus? _selectedEmotion;
  MilestoneVisibility _selectedVisibility = MilestoneVisibility.private;
  final _contentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialMilestone != null) {
      _selectedEmotion = widget.initialMilestone!.emotionStatus;
      _selectedVisibility = widget.initialMilestone!.visibility;
      if (widget.initialMilestone!.content != null) {
        _contentController.text = widget.initialMilestone!.content!;
      }
    } else {
      _selectedVisibility = MilestoneVisibility.public;
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Color _getEmotionColor(EmotionStatus status) {
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

  IconData _getEmotionIcon(EmotionStatus status) {
    switch (status) {
      case EmotionStatus.proud:
        return Icons.emoji_events_rounded;
      case EmotionStatus.hopeful:
        return Icons.wb_sunny_rounded;
      case EmotionStatus.anxious:
        return Icons.waves_rounded;
      case EmotionStatus.grieving:
        return Icons.opacity_rounded;
      case EmotionStatus.neutral:
      default:
        return Icons.sentiment_neutral_rounded;
    }
  }

  String _getEmotionLabel(EmotionStatus status) {
    switch (status) {
      case EmotionStatus.proud:
        return 'Proud';
      case EmotionStatus.hopeful:
        return 'Hopeful';
      case EmotionStatus.anxious:
        return 'Anxious';
      case EmotionStatus.grieving:
        return 'Grieving';
      case EmotionStatus.neutral:
      default:
        return 'Okay';
    }
  }

  Widget _buildEmotionChip(EmotionStatus status) {
    final isSelected = _selectedEmotion == status;
    final theme = Theme.of(context);
    final color = _getEmotionColor(status);
    final icon = _getEmotionIcon(status);
    final label = _getEmotionLabel(status);

    return GestureDetector(
      onTap: () => setState(() => _selectedEmotion = status),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.15)
              : theme.colorScheme.surface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? color
                : theme.dividerColor.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected ? color : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: isSelected ? color : theme.colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEditing = widget.initialMilestone != null;

    // Determine gradient based on selected emotion
    Color primaryGlow = _selectedEmotion != null
        ? _getEmotionColor(_selectedEmotion!)
        : theme.colorScheme.primary;

    // Check if it's a floating check-in (no journey ID from constructor and no journey ID from existing milestone)
    final bool isFloating =
        widget.initialJourneyId == null &&
        (widget.initialMilestone?.journeyId == null);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Full screen glassmorphism background
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              color: theme.scaffoldBackgroundColor.withValues(alpha: 0.75),
            ),
          ),

          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 20.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: theme.colorScheme.surface,
                                border: Border.all(
                                  color: theme.dividerColor.withValues(
                                    alpha: 0.2,
                                  ),
                                ),
                              ),
                              child: IconButton(
                                onPressed: () => Navigator.of(context).pop(),
                                icon: const Icon(Icons.close_rounded, size: 24),
                                style: IconButton.styleFrom(
                                  padding: const EdgeInsets.all(12),
                                ),
                              ),
                            ),
                            if (!isFloating)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      theme.colorScheme.primary.withValues(
                                        alpha: 0.15,
                                      ),
                                      theme.colorScheme.secondary.withValues(
                                        alpha: 0.05,
                                      ),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  border: Border.all(
                                    color: theme.colorScheme.primary.withValues(
                                      alpha: 0.2,
                                    ),
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  isEditing ? 'Edit Check-In' : 'New Check-In',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surface,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: theme.dividerColor.withValues(
                                      alpha: 0.2,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  isEditing ? 'Edit Check-In' : 'New Check-In',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 40),

                        // Emotion Selection
                        Text(
                          'Emotion',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          clipBehavior: Clip.none,
                          child: Row(
                            children: [
                              _buildEmotionChip(EmotionStatus.hopeful),
                              const SizedBox(width: 12),
                              _buildEmotionChip(EmotionStatus.proud),
                              const SizedBox(width: 12),
                              _buildEmotionChip(EmotionStatus.neutral),
                              const SizedBox(width: 12),
                              _buildEmotionChip(EmotionStatus.anxious),
                              const SizedBox(width: 12),
                              _buildEmotionChip(EmotionStatus.grieving),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Text Input
                        Text(
                          'Note',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _contentController,
                          maxLines: 6,
                          minLines: 3,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            height: 1.5,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Tap to write your thoughts...',
                            hintStyle: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.5),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: theme.dividerColor.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: theme.dividerColor.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: theme.colorScheme.primary,
                                width: 1,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 18,
                            ),
                            filled: true,
                            fillColor: theme.colorScheme.surface,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Voice Note & Visibility
                        if (isFloating) ...[
                          Text(
                            'Visibility',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              for (final val in MilestoneVisibility.values)
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      right:
                                          val != MilestoneVisibility.values.last
                                          ? 12.0
                                          : 0,
                                    ),
                                    child: Builder(
                                      builder: (context) {
                                        final isSelected =
                                            _selectedVisibility == val;
                                        return GestureDetector(
                                          onTap: () => setState(
                                            () => _selectedVisibility = val,
                                          ),
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 200,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              gradient: isSelected
                                                  ? LinearGradient(
                                                      colors: [
                                                        theme
                                                            .colorScheme
                                                            .primary
                                                            .withValues(
                                                              alpha: 0.15,
                                                            ),
                                                        theme
                                                            .colorScheme
                                                            .secondary
                                                            .withValues(
                                                              alpha: 0.05,
                                                            ),
                                                      ],
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                    )
                                                  : null,
                                              color: isSelected
                                                  ? null
                                                  : theme.colorScheme.surface,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                color: isSelected
                                                    ? theme.colorScheme.primary
                                                          .withValues(
                                                            alpha: 0.5,
                                                          )
                                                    : theme
                                                          .colorScheme
                                                          .outlineVariant
                                                          .withValues(
                                                            alpha: 0.5,
                                                          ),
                                                width: isSelected ? 1.5 : 1,
                                              ),
                                            ),
                                            child: Column(
                                              children: [
                                                Icon(
                                                  val ==
                                                          MilestoneVisibility
                                                              .private
                                                      ? Icons
                                                            .lock_outline_rounded
                                                      : val ==
                                                            MilestoneVisibility
                                                                .anonymous
                                                      ? Icons.masks_outlined
                                                      : Icons.public_rounded,
                                                  color: isSelected
                                                      ? theme
                                                            .colorScheme
                                                            .primary
                                                      : theme
                                                            .colorScheme
                                                            .onSurfaceVariant,
                                                  size: 20,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  val.name
                                                          .substring(0, 1)
                                                          .toUpperCase() +
                                                      val.name.substring(1),
                                                  style: theme
                                                      .textTheme
                                                      .labelSmall
                                                      ?.copyWith(
                                                        color: isSelected
                                                            ? theme
                                                                  .colorScheme
                                                                  .primary
                                                            : theme
                                                                  .colorScheme
                                                                  .onSurfaceVariant,
                                                        fontWeight: isSelected
                                                            ? FontWeight.w600
                                                            : FontWeight.normal,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ] else ...[
                          // Voice Note (Only if not floating, as we use the space for visibility on floating)
                          Container(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: theme.colorScheme.outlineVariant
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () {
                                  // TODO: Implement voice notes
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 16,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.mic_none_rounded,
                                        color: theme.colorScheme.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Add Voice Note',
                                        style: TextStyle(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 60),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          child: Consumer(
                            builder: (context, ref, child) {
                              return FilledButton(
                                onPressed:
                                    _selectedEmotion == null || _isSubmitting
                                    ? null
                                    : () async {
                                        setState(() => _isSubmitting = true);
                                        try {
                                          final repo = ref.read(
                                            journeyRepositoryProvider,
                                          );

                                          if (isEditing) {
                                            await repo.updateMilestone(
                                              milestoneId:
                                                  widget.initialMilestone!.id,
                                              emotionStatus: _selectedEmotion!,
                                              content:
                                                  _contentController.text
                                                      .trim()
                                                      .isEmpty
                                                  ? null
                                                  : _contentController.text
                                                        .trim(),
                                              visibility: isFloating
                                                  ? _selectedVisibility
                                                  : null,
                                            );
                                          } else {
                                            await repo.createMilestone(
                                              journeyId:
                                                  widget.initialJourneyId,
                                              emotionStatus: _selectedEmotion!,
                                              content:
                                                  _contentController.text
                                                      .trim()
                                                      .isEmpty
                                                  ? null
                                                  : _contentController.text
                                                        .trim(),
                                              visibility: isFloating
                                                  ? _selectedVisibility
                                                  : MilestoneVisibility.public,
                                            );
                                          }

                                          // Invalidate providers
                                          final targetJourneyId =
                                              widget.initialJourneyId ??
                                              widget
                                                  .initialMilestone
                                                  ?.journeyId;
                                          if (targetJourneyId != null) {
                                            ref.invalidate(
                                              journeyMilestonesProvider(
                                                targetJourneyId,
                                              ),
                                            );
                                          } else {
                                            ref.invalidate(
                                              myFloatingMilestonesProvider,
                                            );
                                          }

                                          // Generally invalidate the public feed too
                                          ref.invalidate(togetherFeedProvider);

                                          if (context.mounted) {
                                            Navigator.of(context).pop();
                                          }
                                        } catch (e) {
                                          setState(() => _isSubmitting = false);
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Failed to save check-in: $e',
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                style: FilledButton.styleFrom(
                                  backgroundColor: primaryGlow,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 20,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  elevation: _selectedEmotion == null ? 0 : 8,
                                  shadowColor: primaryGlow.withValues(
                                    alpha: 0.4,
                                  ),
                                ),
                                child: _isSubmitting
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        isEditing
                                            ? 'Save Changes'
                                            : (widget.initialJourneyId != null
                                                  ? 'Log Step'
                                                  : 'Post Check-In'),
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

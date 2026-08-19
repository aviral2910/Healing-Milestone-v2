import 'package:healing_milestones/features/journey/presentation/widgets/audio_player_widget.dart';
import 'dart:ui';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';
import '../../../posts/data/story_providers.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/journey_models.dart';
import '../../../auth/data/auth_provider.dart';
import '../../../../core/models/user_model.dart';
import '../../data/providers/journey_providers.dart';
import '../../data/providers/paginated_journey_milestones_provider.dart';
import 'package:healing_milestones/shared/widgets/app_loader.dart';
import '../../../posts/data/story_providers.dart';

class LogMilestoneOverlay extends ConsumerStatefulWidget {
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
  ConsumerState<LogMilestoneOverlay> createState() => _LogMilestoneOverlayState();
}

class _LogMilestoneOverlayState extends ConsumerState<LogMilestoneOverlay> {
  EmotionStatus? _selectedEmotion;
  MilestoneVisibility _selectedVisibility = MilestoneVisibility.private;
  final _contentController = TextEditingController();
  bool _isSubmitting = false;

  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  String? _audioPath;


  @override
  void initState() {
    super.initState();
    if (widget.initialMilestone != null) {
      _selectedEmotion = widget.initialMilestone!.emotionStatus;
      _selectedVisibility = widget.initialMilestone!.visibility;
      _selectedTag = widget.initialMilestone!.professionalTag;
      if (widget.initialMilestone!.content != null) {
        _contentController.text = widget.initialMilestone!.content!;
      }
    } else {
      _selectedVisibility = MilestoneVisibility.public;
    }

    if (widget.initialMilestone?.mediaUrl != null) {
      // Handle media later
    }
    
    if (widget.initialMilestone?.audioUrl != null && widget.initialMilestone!.audioUrl!.isNotEmpty) {
      _audioPath = widget.initialMilestone!.audioUrl;
    }

  }

  @override
  void dispose() {
    _contentController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }


  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final dir = await getTemporaryDirectory();
        final path = '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
        await _audioRecorder.start(
          const RecordConfig(encoder: AudioEncoder.aacLc),
          path: path,
        );
        setState(() {
          _isRecording = true;
          _audioPath = null;
        });
      }
    } catch (e) {
      debugPrint('Error starting record: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
        _audioPath = path;
      });

    } catch (e) {
      debugPrint('Error stopping record: $e');
    }
  }

  void _deleteRecording() {
    setState(() {
      _audioPath = null;
    });
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

  Widget _buildProfessionalTagChip(ProfessionalTag tag) {
    final isSelected = _selectedTag == tag;
    final theme = Theme.of(context);
    final tagColor = const Color(0xFF00B4D8);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _selectedTag = tag),
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? tagColor.withValues(alpha: 0.15) : theme.colorScheme.surface,
              border: Border.all(
                color: isSelected ? tagColor : theme.dividerColor.withValues(alpha: 0.2),
                width: isSelected ? 1.5 : 1,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: tagColor.withValues(alpha: 0.2),
                        blurRadius: 12,
                        spreadRadius: -2,
                      )
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.local_offer_rounded,
                  size: 16,
                  color: isSelected ? tagColor : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  tag.name.toUpperCase(),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: isSelected ? tagColor : theme.colorScheme.onSurfaceVariant,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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

  ProfessionalTag? _selectedTag;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final isDoctor = user?.role == UserRole.healthcareProfessional || user?.role == UserRole.organization;
    final Color authorityColor = const Color(0xFF00B4D8);

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

                        const SizedBox(height: 16),
                        // Audio Recorder Section
                        if (_isRecording)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.red.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.mic, color: Colors.red),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text('Recording...', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.stop_circle, color: Colors.red, size: 32),
                                  onPressed: _stopRecording,
                                ),
                              ],
                            ),
                          )
                        else if (_audioPath != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                AudioPlayerWidget(audioUrl: _audioPath!, isMini: true),
                                const SizedBox(height: 8),
                                TextButton.icon(
                                  onPressed: _deleteRecording,
                                  icon: const Icon(Icons.delete, size: 20),
                                  label: const Text('Delete Recording'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: theme.colorScheme.error,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Row(
                            children: [
                              TextButton.icon(
                                onPressed: _startRecording,
                                icon: const Icon(Icons.mic),
                                label: const Text('Add Voice Note'),
                                style: TextButton.styleFrom(
                                  foregroundColor: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),

                        const SizedBox(height: 24),

                        // Selection (Emotion vs Tag)
                        if (isDoctor) ...[
                          Text(
                            'Update Type',
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
                                _buildProfessionalTagChip(ProfessionalTag.healthTip),
                                const SizedBox(width: 12),
                                _buildProfessionalTagChip(ProfessionalTag.protocol),
                                const SizedBox(width: 12),
                                _buildProfessionalTagChip(ProfessionalTag.caseStudy),
                                const SizedBox(width: 12),
                                _buildProfessionalTagChip(ProfessionalTag.findings),
                                const SizedBox(width: 12),
                                _buildProfessionalTagChip(ProfessionalTag.research),
                                const SizedBox(width: 12),
                                _buildProfessionalTagChip(ProfessionalTag.announcement),
                              ],
                            ),
                          ),
                        ] else ...[
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
                        ],
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
                                    (isDoctor ? _selectedTag == null : _selectedEmotion == null) || _isSubmitting || _contentController.text.trim().isEmpty
                                    ? null
                                    : () async {
                                        setState(() => _isSubmitting = true);
                                        try {
                                          final repo = ref.read(
                                            journeyRepositoryProvider,
                                          );
                                          
                                          String? audioUrl;
                                          if (_audioPath != null && !_audioPath!.startsWith('http')) {
                                            final r2 = ref.read(storageRepositoryProvider);
                                            audioUrl = await r2.uploadAudio(File(_audioPath!));
                                          } else if (_audioPath != null) {
                                            audioUrl = _audioPath;
                                          }

                                          if (isEditing) {
                                            if (widget.initialMilestone?.audioUrl != null && audioUrl != widget.initialMilestone!.audioUrl) {
                                              try {
                                                ref.read(storageRepositoryProvider).deleteImageFromUrl(widget.initialMilestone!.audioUrl!);
                                              } catch (e) {
                                                debugPrint('Failed to delete orphaned audio: $e');
                                              }
                                            }
                                            
                                            await repo.updateMilestone(
                                              milestoneId:
                                                  widget.initialMilestone!.id,
                                              emotionStatus: isDoctor ? null : _selectedEmotion,
                                              professionalTag: isDoctor ? _selectedTag : null,
                                              audioUrl: audioUrl,
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
                                              emotionStatus: isDoctor ? null : _selectedEmotion,
                                              professionalTag: isDoctor ? _selectedTag : null,
                                              audioUrl: audioUrl,
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
                                              paginatedJourneyMilestonesProvider(
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
                                        child: const AppLoader.small(),
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

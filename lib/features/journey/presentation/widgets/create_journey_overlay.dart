import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/journey_providers.dart';
import '../../data/models/journey_models.dart';
import '../../../auth/data/auth_provider.dart';
import '../../../../core/models/user_model.dart';
import 'package:healing_milestones/shared/widgets/app_loader.dart';

class CreateJourneyOverlay extends ConsumerStatefulWidget {
  final JourneyModel? initialJourney;

  const CreateJourneyOverlay({Key? key, this.initialJourney}) : super(key: key);

  static Future<void> show(BuildContext context, {JourneyModel? journey}) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return CreateJourneyOverlay(initialJourney: journey);
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
  ConsumerState<CreateJourneyOverlay> createState() => _CreateJourneyOverlayState();
}

class _CreateJourneyOverlayState extends ConsumerState<CreateJourneyOverlay> {
  final _titleController = TextEditingController();
  final _categoryController = TextEditingController();
  MilestoneVisibility _visibility = MilestoneVisibility.public;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialJourney != null) {
      _titleController.text = widget.initialJourney!.title;
      _categoryController.text = widget.initialJourney!.category;
      _visibility = widget.initialJourney!.visibility;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  JourneyType _selectedType = JourneyType.personal;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final isDoctor = user?.role == UserRole.healthcareProfessional || user?.role == UserRole.organization;
    final Color authorityColor = const Color(0xFF00B4D8);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEditing = widget.initialJourney != null;

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
                                isEditing ? 'Edit Folder' : 'New Folder',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 60),

                        // Title
                        Text(
                          isEditing ? 'Update Journey' : 'New Journey',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Journey Title Input
                        Text(
                          'Journey Name',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _titleController,
                          maxLength: 25,
                          autofocus:
                              !isEditing, // Focus instantly so they find it
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            hintText: 'e.g. Mental Health Reset',
                            hintStyle: TextStyle(
                              fontWeight: FontWeight.normal,
                              color: theme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.5),
                            ),
                            counterStyle: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.6),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
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
                        const SizedBox(height: 24),

                        // Category Input
                        Text(
                          'Category (Optional)',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _categoryController,
                          maxLength: 25,
                          style: theme.textTheme.bodyLarge,
                          decoration: InputDecoration(
                            hintText: 'e.g. Physical Recovery, Grief, Career',
                            hintStyle: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.5),
                            ),
                            counterStyle: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.6),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
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

                        const SizedBox(height: 24),
                        Text(
                          'Visibility',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildVisibilityOption(
                                'Public',
                                Icons.public,
                                MilestoneVisibility.public,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildVisibilityOption(
                                'Anonymous',
                                Icons.visibility_off_rounded,
                                MilestoneVisibility.anonymous,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildVisibilityOption(
                                'Private',
                                Icons.lock_outline,
                                MilestoneVisibility.private,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 60),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          child: Consumer(
                            builder: (context, ref, child) {
                              return FilledButton(
                                onPressed: _isSubmitting
                                    ? null
                                    : () async {
                                        if (_titleController.text
                                            .trim()
                                            .isEmpty)
                                          return;

                                        setState(() => _isSubmitting = true);
                                        try {
                                          final repo = ref.read(
                                            journeyRepositoryProvider,
                                          );
                                          if (isEditing) {
                                            await repo.updateJourney(
                                              widget.initialJourney!.id,
                                              _titleController.text.trim(),
                                              _categoryController.text
                                                      .trim()
                                                      .isEmpty
                                                  ? 'General'
                                                  : _categoryController.text
                                                        .trim(),
                                              _visibility,
                                            );
                                          } else {
                                            await repo.createJourney(
                                              _titleController.text.trim(),
                                              _categoryController.text
                                                      .trim()
                                                      .isEmpty
                                                  ? 'General'
                                                  : _categoryController.text
                                                        .trim(),
                                              _visibility,
                                            );
                                          }
                                          ref.invalidate(myJourneysProvider);
                                          ref.invalidate(
                                            journeyMilestonesProvider,
                                          );
                                          ref.invalidate(togetherFeedProvider);
                                          ref.invalidate(
                                            myFloatingMilestonesProvider,
                                          );
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
                                                  'Failed to save journey: $e',
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 20,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  elevation: 8,
                                  shadowColor: theme.colorScheme.primary
                                      .withValues(alpha: 0.4),
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
                                            : 'Create Journey',
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

  Widget _buildVisibilityOption(
    String title,
    IconData icon,
    MilestoneVisibility value,
  ) {
    final theme = Theme.of(context);
    final isSelected = _visibility == value;

    return GestureDetector(
      onTap: () => setState(() => _visibility = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.15),
                    theme.colorScheme.secondary.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary.withValues(alpha: 0.5)
                : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

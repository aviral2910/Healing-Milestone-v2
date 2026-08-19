import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healing_milestones/shared/widgets/app_loader.dart';
import '../../data/providers/journey_providers.dart';
import '../../data/providers/paginated_journey_milestones_provider.dart';

class ReopenJourneyOverlay extends ConsumerStatefulWidget {
  final String journeyId;

  const ReopenJourneyOverlay({Key? key, required this.journeyId}) : super(key: key);

  static Future<void> show(BuildContext context, {required String journeyId}) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return ReopenJourneyOverlay(journeyId: journeyId);
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ),
          child: SlideTransition(
            position: Tween<Offset>(
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
  ConsumerState<ReopenJourneyOverlay> createState() => _ReopenJourneyOverlayState();
}

class _ReopenJourneyOverlayState extends ConsumerState<ReopenJourneyOverlay> {
  final _contentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _contentController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please share a thought before resuming')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final repo = ref.read(journeyRepositoryProvider);
      await repo.reopenJourney(widget.journeyId, text);
      
      ref.invalidate(paginatedJourneyMilestonesProvider(widget.journeyId));
      ref.invalidate(myJourneysProvider);
      ref.invalidate(togetherFeedProvider);
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Your journey has been resumed. 🌱')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryGlow = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
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
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
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
                                  color: theme.dividerColor.withValues(alpha: 0.2),
                                ),
                              ),
                              child: IconButton(
                                onPressed: () => Navigator.of(context).pop(),
                                icon: const Icon(Icons.close_rounded, size: 24),
                                style: IconButton.styleFrom(padding: const EdgeInsets.all(12)),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    primaryGlow.withValues(alpha: 0.15),
                                    primaryGlow.withValues(alpha: 0.05),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                border: Border.all(color: primaryGlow.withValues(alpha: 0.2)),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Resume Journey',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: primaryGlow,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        
                        // Hero Icon
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: primaryGlow.withValues(alpha: 0.1),
                              border: Border.all(color: primaryGlow.withValues(alpha: 0.3), width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryGlow.withValues(alpha: 0.2),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Icon(Icons.energy_savings_leaf_rounded, size: 64, color: primaryGlow),
                          ),
                        ),
                        const SizedBox(height: 32),

                        Text(
                          'Continue Your Journey',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Healing is not a straight line. What made you decide to resume this journey today?',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.5,
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
                          minLines: 4,
                          maxLength: 1000,
                          textInputAction: TextInputAction.done,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            height: 1.5,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Share a thought, a setback, or a new realization...',
                            hintStyle: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                            ),
                            filled: true,
                            fillColor: theme.colorScheme.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: theme.dividerColor.withValues(alpha: 0.5),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: theme.dividerColor.withValues(alpha: 0.5),
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
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _isSubmitting ? null : _submit,
                            style: FilledButton.styleFrom(
                              backgroundColor: primaryGlow,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              elevation: 8,
                              shadowColor: primaryGlow.withValues(alpha: 0.4),
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: AppLoader.small(),
                                  )
                                : const Text(
                                    'Resume Journey',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
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

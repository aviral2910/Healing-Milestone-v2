import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healing_milestones/features/journey/presentation/providers/time_capsule_provider.dart';

class CreateTimeCapsuleOverlay extends StatefulWidget {
  const CreateTimeCapsuleOverlay({super.key});

  static Future<void> show(BuildContext context) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const CreateTimeCapsuleOverlay();
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
  State<CreateTimeCapsuleOverlay> createState() =>
      _CreateTimeCapsuleOverlayState();
}

class _CreateTimeCapsuleOverlayState extends State<CreateTimeCapsuleOverlay> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  int? _selectedMonths = 1;
  DateTime? _customDate;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickCustomDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 100)),
    );
    if (picked != null) {
      setState(() {
        _customDate = picked;
        _selectedMonths = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Full screen glassmorphism background
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              color: theme.scaffoldBackgroundColor.withValues(alpha: 0.85),
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
                                    baseColor.withValues(alpha: 0.15),
                                    baseColor.withValues(alpha: 0.05),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                border: Border.all(
                                  color: baseColor.withValues(alpha: 0.2),
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Time Capsule',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: baseColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),

                        // Title Input
                        Text(
                          'Seal a Memory',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 32),

                        Text(
                          'Capsule Title',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _titleController,
                          maxLength: 40,
                          autofocus: true,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            hintText: 'e.g. To my 30th Birthday Self',
                            hintStyle: TextStyle(
                              fontWeight: FontWeight.normal,
                              color: theme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.5),
                            ),
                            counterStyle: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.6),
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
                                color: baseColor,
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
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 24),

                        // Message Input
                        Text(
                          'Your Message',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _contentController,
                          maxLines: 8,
                          minLines: 5,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            height: 1.6,
                          ),
                          decoration: InputDecoration(
                            hintText:
                                'Write something you want your future self to remember...',
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
                                color: baseColor,
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
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 32),

                        // Unlock Date
                        Row(
                          children: [
                            Icon(
                              Icons.lock_clock_rounded,
                              color: baseColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'When to unlock?',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: [
                              ChoiceChip(
                                label: Text(
                                  _customDate != null
                                      ? _customDate!.toLocal().toString().split(
                                          ' ',
                                        )[0]
                                      : "Custom Date",
                                ),
                                selected: _customDate != null,
                                onSelected: (_) => _pickCustomDate(),
                                selectedColor: baseColor.withValues(
                                  alpha: 0.15,
                                ),
                                backgroundColor: theme.colorScheme.surface,
                                showCheckmark: false,
                                labelStyle: TextStyle(
                                  color: _customDate != null
                                      ? baseColor
                                      : theme.colorScheme.onSurfaceVariant,
                                  fontWeight: _customDate != null
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(
                                    color: _customDate != null
                                        ? baseColor.withValues(alpha: 0.5)
                                        : theme.dividerColor.withValues(
                                            alpha: 0.5,
                                          ),
                                    width: _customDate != null ? 1.5 : 1,
                                  ),
                                ),
                              ),
                              ...[1, 3, 6, 12].map((months) {
                                final isSelected = _selectedMonths == months;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 12.0),
                                  child: ChoiceChip(
                                    label: Text(
                                      "$months Month${months > 1 ? 's' : ''}",
                                    ),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      if (selected) {
                                        setState(() {
                                          _selectedMonths = months;
                                          _customDate = null;
                                        });
                                      }
                                    },
                                    selectedColor: baseColor.withValues(
                                      alpha: 0.15,
                                    ),
                                    backgroundColor: theme.colorScheme.surface,
                                    showCheckmark: false,
                                    labelStyle: TextStyle(
                                      color: isSelected
                                          ? baseColor
                                          : theme.colorScheme.onSurfaceVariant,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      side: BorderSide(
                                        color: isSelected
                                            ? baseColor.withValues(alpha: 0.5)
                                            : theme.dividerColor.withValues(
                                                alpha: 0.5,
                                              ),
                                        width: isSelected ? 1.5 : 1,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),

                        const SizedBox(height: 60),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          child: Consumer(
                            builder: (context, ref, child) {
                              final isValid =
                                  _titleController.text.trim().isNotEmpty &&
                                  _contentController.text.trim().isNotEmpty;
                              return FilledButton(
                                onPressed: (_isSubmitting || !isValid)
                                    ? null
                                    : () async {
                                        setState(() => _isSubmitting = true);
                                        try {
                                          DateTime unlockDate;
                                          if (_customDate != null) {
                                            unlockDate = _customDate!;
                                          } else {
                                            unlockDate = DateTime.now().add(
                                              Duration(
                                                days:
                                                    (_selectedMonths ?? 6) * 30,
                                              ),
                                            );
                                          }

                                          await ref
                                              .read(
                                                myTimeCapsulesProvider.notifier,
                                              )
                                              .addCapsule(
                                                _titleController.text.trim(),
                                                _contentController.text.trim(),
                                                unlockDate,
                                              );

                                          if (context.mounted) {
                                            Navigator.of(context).pop();
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: const Text(
                                                  "Time Capsule sealed!",
                                                ),
                                                backgroundColor: baseColor
                                                    .withValues(alpha: 0.9),
                                              ),
                                            );
                                          }
                                        } catch (e) {
                                          setState(() => _isSubmitting = false);
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  "Failed to seal capsule.",
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                style: FilledButton.styleFrom(
                                  backgroundColor: baseColor,
                                  foregroundColor: theme.colorScheme.onPrimary,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 20,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  elevation: 8,
                                  shadowColor: baseColor.withValues(alpha: 0.4),
                                ),
                                child: _isSubmitting
                                    ? SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: theme.colorScheme.onPrimary,
                                        ),
                                      )
                                    : Text(
                                        'Seal Capsule',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.2,
                                          color: theme.colorScheme.onPrimary,
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

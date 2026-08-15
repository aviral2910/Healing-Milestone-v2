import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:healing_milestones/core/models/time_capsule_model.dart';

class TimeCapsuleCard extends StatelessWidget {
  final TimeCapsuleModel? activeCapsule;
  final VoidCallback onOpen;

  const TimeCapsuleCard({
    Key? key,
    this.activeCapsule,
    required this.onOpen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasCapsule = activeCapsule != null;
    final isLocked = hasCapsule && activeCapsule!.isLocked && !activeCapsule!.isOpened;
    final isReadyToOpen = hasCapsule && !activeCapsule!.isLocked && !activeCapsule!.isOpened;
    final isOpened = hasCapsule && activeCapsule!.isOpened;

    // Use a very soft amber / organic color base
    final baseColor = const Color(0xFFFFC107); // Amber

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: isReadyToOpen
                ? [baseColor.withValues(alpha: 0.8), baseColor.withValues(alpha: 0.5)]
                : [
                    theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: isReadyToOpen
                ? baseColor.withValues(alpha: 0.6)
                : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: isReadyToOpen
              ? [
                  BoxShadow(
                    color: baseColor.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  )
                ]
              : [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (!hasCapsule || isOpened) {
                    context.push('/create-time-capsule');
                  } else if (isReadyToOpen) {
                    onOpen();
                  } else if (isLocked) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Patience! Your future self isn't ready yet."),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isReadyToOpen
                              ? theme.scaffoldBackgroundColor.withValues(alpha: 0.9)
                              : theme.colorScheme.surface,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              spreadRadius: 1,
                            )
                          ],
                        ),
                        child: Icon(
                          _getIcon(isLocked, isReadyToOpen, isOpened, hasCapsule),
                          color: isReadyToOpen ? baseColor : theme.colorScheme.onSurface,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getTitle(isLocked, isReadyToOpen, isOpened, hasCapsule),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isReadyToOpen ? Colors.black87 : theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _getSubtitle(isLocked, isReadyToOpen, isOpened, hasCapsule, activeCapsule),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: isReadyToOpen 
                                    ? Colors.black54 
                                    : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!isLocked)
                        Icon(
                          Icons.chevron_right,
                          color: isReadyToOpen ? Colors.black54 : theme.colorScheme.onSurfaceVariant,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIcon(bool isLocked, bool isReadyToOpen, bool isOpened, bool hasCapsule) {
    if (!hasCapsule || isOpened) return Icons.edit_note_rounded;
    if (isReadyToOpen) return Icons.mark_email_unread_rounded;
    return Icons.lock_clock_rounded;
  }

  String _getTitle(bool isLocked, bool isReadyToOpen, bool isOpened, bool hasCapsule) {
    if (!hasCapsule || isOpened) return "Time Capsule";
    if (isReadyToOpen) return "A message awaits!";
    return "Time Capsule Sealed";
  }

  String _getSubtitle(bool isLocked, bool isReadyToOpen, bool isOpened, bool hasCapsule, TimeCapsuleModel? capsule) {
    if (!hasCapsule || isOpened) return "Write a letter to your future self.";
    if (isReadyToOpen) return "Your past self has something to say. Tap to unlock.";
    
    if (capsule != null) {
      final days = capsule.unlockDate.difference(DateTime.now()).inDays;
      if (days > 1) {
        return "Unlocks in $days days.";
      } else {
        final hours = capsule.unlockDate.difference(DateTime.now()).inHours;
        return "Unlocks in $hours hours.";
      }
    }
    return "Locked.";
  }
}

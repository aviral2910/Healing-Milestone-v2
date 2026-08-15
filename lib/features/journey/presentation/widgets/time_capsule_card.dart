import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:healing_milestones/core/models/time_capsule_model.dart';
import 'package:healing_milestones/features/journey/presentation/providers/time_capsule_provider.dart';

class TimeCapsuleCard extends ConsumerWidget {
  final TimeCapsuleModel? activeCapsule;
  final VoidCallback onOpen;
  final VoidCallback? onLongPress;
  final int lockedCount;

  const TimeCapsuleCard({
    Key? key,
    this.activeCapsule,
    required this.onOpen,
    this.onLongPress,
    this.lockedCount = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final hasCapsule = activeCapsule != null;
    final isLocked =
        hasCapsule && activeCapsule!.isLocked && !activeCapsule!.isOpened;
    final isReadyToOpen =
        hasCapsule && !activeCapsule!.isLocked && !activeCapsule!.isOpened;
    final isOpened = hasCapsule && activeCapsule!.isOpened;

    final baseColor = theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: isReadyToOpen
                ? [
                    baseColor.withValues(alpha: 0.8),
                    baseColor.withValues(alpha: 0.5),
                  ]
                : [
                    baseColor.withValues(alpha: 0.1),
                    baseColor.withValues(alpha: 0.02),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: isReadyToOpen
                ? baseColor.withValues(alpha: 0.8)
                : baseColor.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: isReadyToOpen
              ? [
                  BoxShadow(
                    color: baseColor.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
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
                onTap: onOpen,
                onLongPress: onLongPress,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isReadyToOpen
                              ? theme.scaffoldBackgroundColor.withOpacity(0.9)
                              : theme.colorScheme.surface,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Icon(
                          _getIcon(
                            isLocked,
                            isReadyToOpen,
                            isOpened,
                            hasCapsule,
                          ),
                          color: baseColor,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getTitle(
                                isLocked,
                                isReadyToOpen,
                                isOpened,
                                hasCapsule,
                              ),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isReadyToOpen
                                    ? theme.colorScheme.onPrimary
                                    : theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _getSubtitle(
                                isLocked,
                                isReadyToOpen,
                                isOpened,
                                hasCapsule,
                                activeCapsule,
                              ),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: isReadyToOpen
                                    ? theme.colorScheme.onPrimary.withOpacity(
                                        0.8,
                                      )
                                    : theme.colorScheme.onSurface.withOpacity(
                                        0.7,
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!isLocked && onLongPress == null)
                        Icon(
                          Icons.chevron_right,
                          color: isReadyToOpen
                              ? theme.colorScheme.onPrimary.withOpacity(0.8)
                              : theme.colorScheme.onSurfaceVariant,
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

  IconData _getIcon(
    bool isLocked,
    bool isReadyToOpen,
    bool isOpened,
    bool hasCapsule,
  ) {
    if (!hasCapsule) return Icons.lock_clock_rounded;
    if (isOpened) return Icons.drafts_rounded;
    if (isReadyToOpen) return Icons.mark_email_unread_rounded;
    return Icons.lock_clock_rounded;
  }

  String _getTitle(
    bool isLocked,
    bool isReadyToOpen,
    bool isOpened,
    bool hasCapsule,
  ) {
    if (!hasCapsule) return "Time Capsule Vault";
    final title = activeCapsule!.title.trim();
    if (title.isEmpty || title == 'Untitled Capsule') {
      final date = activeCapsule!.createdAt.toLocal();
      final month = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][date.month - 1];
      return "Memory from $month ${date.day}, ${date.year}";
    }
    return title;
  }

  String _getSubtitle(
    bool isLocked,
    bool isReadyToOpen,
    bool isOpened,
    bool hasCapsule,
    TimeCapsuleModel? capsule,
  ) {
    if (!hasCapsule) {
      if (lockedCount > 0)
        return "$lockedCount sealed capsule${lockedCount > 1 ? 's' : ''} inside. Tap to enter.";
      return "Tap to enter the vault.";
    }
    if (isReadyToOpen) return "A message from your past awaits! Tap to unlock.";
    if (isOpened) return "Opened.";

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

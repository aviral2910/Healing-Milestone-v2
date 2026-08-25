import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healing_milestones/core/models/time_capsule_model.dart';

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
                    color: baseColor.withValues(alpha: 0.3),
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
                              ? theme.scaffoldBackgroundColor.withValues(alpha: 0.9)
                              : theme.colorScheme.surface,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
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
                            _buildSubtitle(
                              isLocked,
                              isReadyToOpen,
                              isOpened,
                              hasCapsule,
                              activeCapsule,
                              theme,
                            ),
                          ],
                        ),
                      ),
                      if (!isLocked && onLongPress == null)
                        Icon(
                          Icons.chevron_right,
                          color: isReadyToOpen
                              ? theme.colorScheme.onPrimary.withValues(alpha: 0.8)
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

  String _formatDate(DateTime date) {
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final ampm = date.hour >= 12 ? 'PM' : 'AM';
    final hr = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final min = date.minute.toString().padLeft(2, '0');
    return "${months[date.month - 1]} ${date.day}, ${date.year}\n$hr:$min $ampm";
  }

  Widget _buildSubtitle(
    bool isLocked,
    bool isReadyToOpen,
    bool isOpened,
    bool hasCapsule,
    TimeCapsuleModel? capsule,
    ThemeData theme,
  ) {
    final style = theme.textTheme.bodySmall?.copyWith(
      color: isReadyToOpen
          ? theme.colorScheme.onPrimary.withValues(alpha: 0.8)
          : theme.colorScheme.onSurface.withValues(alpha: 0.6),
      height: 1.5,
    );

    if (!hasCapsule) {
      final text = lockedCount > 0
          ? "$lockedCount sealed capsule${lockedCount > 1 ? 's' : ''} inside. Tap to enter."
          : "Tap to enter the vault.";
      return Text(text, style: style);
    }
    
    if (capsule == null) return const SizedBox.shrink();

    final sealedDate = _formatDate(capsule.createdAt.toLocal());
    final unlockDate = _formatDate(capsule.unlockDate.toLocal());

    Widget buildDateRow(String label1, String value1, String label2, String value2) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label1, style: theme.textTheme.labelSmall?.copyWith(color: style?.color?.withValues(alpha: 0.7), fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(value1, style: style?.copyWith(fontWeight: FontWeight.bold, height: 1.3)),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label2, style: theme.textTheme.labelSmall?.copyWith(color: style?.color?.withValues(alpha: 0.7), fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(value2, style: style?.copyWith(fontWeight: FontWeight.bold, height: 1.3)),
              ],
            ),
          ),
        ],
      );
    }

    if (isReadyToOpen) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildDateRow("SEALED", sealedDate, "TARGET", unlockDate),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.key, size: 16, color: theme.colorScheme.onPrimary),
                const SizedBox(width: 6),
                Text(
                  "Ready to unlock!",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (isOpened) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildDateRow("SEALED", sealedDate, "OPENED", unlockDate),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
            ),
            child: Text(
              "Opened",
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      );
    }

    if (isLocked) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildDateRow("SEALED", sealedDate, "UNLOCKS", unlockDate),
          const SizedBox(height: 12),
          StreamBuilder(
            stream: Stream.periodic(const Duration(seconds: 1)),
            builder: (context, snapshot) {
              final diff = capsule.unlockDate.difference(DateTime.now());
              if (diff.isNegative) {
                return Text("Ready to unlock!", style: style);
              }
              final days = diff.inDays;
              final hours = diff.inHours.remainder(24);
              final minutes = diff.inMinutes.remainder(60);
              final seconds = diff.inSeconds.remainder(60);
              
              final timeStr = "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
              final unlockStr = days > 0 ? "$days days, $timeStr" : timeStr;
              
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
                      theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.15)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lock_clock, size: 20, color: theme.colorScheme.primary.withValues(alpha: 0.8)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Time Remaining",
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Text(
                      unlockStr,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontFeatures: const [FontFeature.tabularFigures()],
                        color: theme.colorScheme.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      );
    }
    
    return const SizedBox.shrink();
  }
}

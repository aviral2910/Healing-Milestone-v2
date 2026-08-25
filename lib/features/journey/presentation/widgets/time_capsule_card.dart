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

  String _formatDateShort(DateTime date) {
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return "${months[date.month - 1]} ${date.day}, ${date.year}";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final hasCapsule = activeCapsule != null;

    return StreamBuilder(
      stream: Stream.periodic(const Duration(seconds: 1)),
      builder: (context, snapshot) {
        final now = DateTime.now();
        final isLocked = hasCapsule && activeCapsule!.unlockDate.isAfter(now) && !activeCapsule!.isOpened;
        final isReadyToOpen = hasCapsule && !activeCapsule!.unlockDate.isAfter(now) && !activeCapsule!.isOpened;
        final isOpened = hasCapsule && activeCapsule!.isOpened;

        final diff = hasCapsule ? activeCapsule!.unlockDate.difference(now) : Duration.zero;
        final clampedDiff = diff.isNegative ? Duration.zero : diff;
        final isImminent = isLocked && clampedDiff.inMinutes < 5;

        // Determine theme colors based on state
        final Color glowColor = isReadyToOpen ? primary : (isOpened ? theme.colorScheme.outline : primary.withValues(alpha: 0.4));
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Stack(
            children: [
              // Subtle glow behind the card
              if (isReadyToOpen || isLocked)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: glowColor.withValues(alpha: isReadyToOpen ? 0.3 : 0.1),
                          blurRadius: 24,
                          spreadRadius: -4,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                  ),
                ),
              
              // Main Card
              ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Material(
                    color: theme.colorScheme.surface.withValues(alpha: 0.7),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                      side: BorderSide(
                        color: glowColor.withValues(alpha: isReadyToOpen ? 0.5 : 0.2),
                        width: 1.5,
                      ),
                    ),
                    child: InkWell(
                      onTap: onOpen,
                      onLongPress: onLongPress,
                      child: isImminent 
                          ? _buildImminentUI(theme, primary, clampedDiff, hasCapsule)
                          : _buildNormalUI(theme, primary, isLocked, isReadyToOpen, isOpened, hasCapsule, clampedDiff),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildImminentUI(ThemeData theme, Color primary, Duration diff, bool hasCapsule) {
    final minutes = diff.inMinutes.remainder(60);
    final seconds = diff.inSeconds.remainder(60);
    final timeStr = "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 12),
          Text(
            _getTitle(true, false, false, hasCapsule),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: primary.withValues(alpha: 0.3), width: 2),
            ),
            child: Text(
              timeStr,
              style: theme.textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.w900,
                fontFeatures: const [FontFeature.tabularFigures()],
                color: primary,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.hourglass_bottom_rounded, size: 16, color: primary),
              const SizedBox(width: 8),
              Text(
                "Unlocking soon...",
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: primary,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNormalUI(ThemeData theme, Color primary, bool isLocked, bool isReadyToOpen, bool isOpened, bool hasCapsule, Duration diff) {
    // Strictly thematic badge colors
    Color badgeColor;
    Color badgeTextColor;
    
    if (!hasCapsule) {
      badgeColor = theme.colorScheme.surfaceContainerHighest;
      badgeTextColor = theme.colorScheme.onSurfaceVariant;
    } else if (isReadyToOpen) {
      badgeColor = theme.colorScheme.primary;
      badgeTextColor = theme.colorScheme.onPrimary;
    } else if (isOpened) {
      badgeColor = theme.colorScheme.secondary;
      badgeTextColor = theme.colorScheme.onSecondary;
    } else {
      // Sealed - Outlined Golden Theme using Primary color
      badgeColor = primary.withValues(alpha: 0.15);
      badgeTextColor = primary;
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TOP ROW: Badge and Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBadge(theme, badgeColor, badgeTextColor, isLocked, isReadyToOpen, isOpened, hasCapsule, primary),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (isReadyToOpen ? primary : (isOpened ? theme.colorScheme.outline : primary.withValues(alpha: 0.4))).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getIcon(isLocked, isReadyToOpen, isOpened, hasCapsule),
                  color: isReadyToOpen ? primary : (isOpened ? theme.colorScheme.outline : primary.withValues(alpha: 0.4)),
                  size: 24,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // MIDDLE: Title
          Text(
            _getTitle(isLocked, isReadyToOpen, isOpened, hasCapsule),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: theme.colorScheme.onSurface,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 24),
          
          // BOTTOM: Info Area
          _buildBottomSection(theme, primary, isLocked, isReadyToOpen, isOpened, hasCapsule, diff),
        ],
      ),
    );
  }

  Widget _buildBadge(ThemeData theme, Color bgColor, Color textColor, bool isLocked, bool isReadyToOpen, bool isOpened, bool hasCapsule, Color primary) {
    String text = "TIME VAULT";
    IconData? icon;
    
    if (hasCapsule) {
      if (isReadyToOpen) { text = "READY TO OPEN"; icon = Icons.key_rounded; }
      else if (isOpened) { text = "OPENED"; }
      else if (isLocked) { text = "SEALED"; }
    }

    final hasGoldBorder = isLocked && hasCapsule;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(100),
        border: hasGoldBorder ? Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.5), width: 1.5) : null,
        boxShadow: [
          BoxShadow(
            color: bgColor.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection(ThemeData theme, Color primary, bool isLocked, bool isReadyToOpen, bool isOpened, bool hasCapsule, Duration diff) {
    if (!hasCapsule) {
      return Text(
        lockedCount > 0 ? "$lockedCount sealed capsules inside." : "Tap to seal a new memory.",
        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
      );
    }

    final startStr = _formatDateShort(activeCapsule!.createdAt.toLocal());
    final endStr = _formatDateShort(activeCapsule!.unlockDate.toLocal());

    if (isReadyToOpen) {
      return Row(
        children: [
          Icon(Icons.auto_awesome, size: 20, color: primary),
          const SizedBox(width: 8),
          Text(
            "Your message is waiting for you.",
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      );
    }

    if (isOpened) {
      return Row(
        children: [
          Icon(Icons.drafts_outlined, size: 20, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7)),
          const SizedBox(width: 8),
          Text(
            "Unlocked on $endStr",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ],
      );
    }

    if (isLocked) {
      final now = DateTime.now();
      final start = activeCapsule!.createdAt;
      final end = activeCapsule!.unlockDate;
      
      final totalDuration = end.difference(start).inSeconds;
      final elapsed = now.difference(start).inSeconds;
      double progress = totalDuration > 0 ? (elapsed / totalDuration) : 1.0;
      progress = progress.clamp(0.0, 1.0);

      final days = diff.inDays;
      final hours = diff.inHours.remainder(24);
      final minutes = diff.inMinutes.remainder(60);
      final seconds = diff.inSeconds.remainder(60);
      
      final timeStr = "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
      final unlockStr = days > 0 ? "$days days, $timeStr" : timeStr;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Time Remaining",
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                unlockStr,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(primary),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                startStr,
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
              ),
              Text(
                endStr,
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
              ),
            ],
          ),
        ],
      );
    }
    
    return const SizedBox.shrink();
  }

  IconData _getIcon(bool isLocked, bool isReadyToOpen, bool isOpened, bool hasCapsule) {
    if (!hasCapsule) return Icons.add_circle_outline_rounded;
    if (isOpened) return Icons.mark_email_read_rounded;
    if (isReadyToOpen) return Icons.lock_open_rounded;
    return Icons.lock_clock_rounded;
  }

  String _getTitle(bool isLocked, bool isReadyToOpen, bool isOpened, bool hasCapsule) {
    if (!hasCapsule) return "Time Capsule Vault";
    final title = activeCapsule!.title.trim();
    if (title.isEmpty || title == 'Untitled Capsule') {
      return "A memory from ${_formatDateShort(activeCapsule!.createdAt.toLocal())}";
    }
    return title;
  }
}

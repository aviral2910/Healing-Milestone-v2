import 'dart:ui';
import 'qr_scan_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../shared/widgets/qr_share_preview.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../features/medical_vault/presentation/providers/medical_vault_providers.dart';
import '../../../../features/medical_vault/data/models/medical_vault_models.dart';
import '../../../../features/journey/presentation/widgets/timeline_node.dart';
import '../../../../features/medical_vault/presentation/widgets/report_timeline_node.dart'
    as rm;
import '../../../../features/journey/data/models/journey_models.dart' as jm;

class HealthSnapshotScreen extends ConsumerStatefulWidget {
  final String snapshotId;

  const HealthSnapshotScreen({super.key, required this.snapshotId});

  @override
  ConsumerState<HealthSnapshotScreen> createState() =>
      _HealthSnapshotScreenState();
}

class _HealthSnapshotScreenState extends ConsumerState<HealthSnapshotScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      ref
          .read(snapshotTimelineProvider(widget.snapshotId).notifier)
          .fetchNextPage();
    }
  }

  void _showRemoveRecordDialog(BuildContext context, MixView view, MedicalRecord record) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning_amber_rounded, size: 48, color: Colors.redAccent),
                const SizedBox(height: 16),
                const Text(
                  'Remove from Snapshot?',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'This will remove the ${record.category == 'prescription' ? 'prescription' : 'report'} from this snapshot. It will NOT be deleted from your Medical Vault.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
                        onPressed: () async {
                          Navigator.pop(ctx);
                          final scaffoldMsg = ScaffoldMessenger.of(context);
                          
                          try {
                            final newIds = view.selectedReportIds.where((id) => id != record.id).toList();
                            await ref.read(mixViewsProvider.notifier).updateMixView(
                              id: view.id,
                              name: view.name,
                              journeyIds: view.journeyIds,
                              selectedReportIds: newIds,
                              durationHours: view.expiresAt.difference(DateTime.now()).inHours > 0 
                                  ? view.expiresAt.difference(DateTime.now()).inHours 
                                  : 1,
                            );
                            ref.read(snapshotTimelineProvider(widget.snapshotId).notifier).removeRecordLocally(record.id);
                            scaffoldMsg.showSnackBar(const SnackBar(content: Text('Removed successfully')));
                          } catch (e) {
                            scaffoldMsg.showSnackBar(SnackBar(content: Text('Failed to remove: $e')));
                          }
                        },
                        child: const Text('Remove'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timelineAsync = ref.watch(
      snapshotTimelineProvider(widget.snapshotId),
    );
    final mixViewsAsync = ref.watch(mixViewsProvider);

    // We get the basic view details to show in the AppBar/Header
    final view = mixViewsAsync.value?.firstWhere(
      (v) => v.id == widget.snapshotId,
      orElse: () => MixView(
        id: '',
        userId: '',
        name: 'Health Snapshot',
        journeyIds: [],
        selectedReportIds: [],
        expiresAt: DateTime.now(),
        createdAt: DateTime.now(),
      ),
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar.large(
            pinned: true,
            title: Text(
              view?.name ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/journey');
                }
              },
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: IconButton(
                  icon: const Icon(Icons.more_horiz_rounded),
                  onPressed: () {
                    if (view == null) return;
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => _SnapshotOptionsSheet(view: view),
                    );
                  },
                ),
              ),
            ],
          ),

          timelineAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(child: Text('Error loading timeline: $e')),
            ),
            data: (items) {
              if (items.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 64,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No events found',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 24,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == items.length) {
                        return Consumer(
                          builder: (context, ref, child) {
                            final isLoading = ref
                                .watch(
                                  snapshotTimelineProvider(
                                    widget.snapshotId,
                                  ).notifier,
                                )
                                .isLoadingMore;
                            if (isLoading) {
                              return const Padding(
                                padding: EdgeInsets.all(32.0),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            return const SizedBox(height: 100);
                          },
                        );
                      }

                      final item = items[index];

                      final currentDate = DateTime(
                        item.date.year,
                        item.date.month,
                        item.date.day,
                      );

                      bool isFirstOfDay = true;
                      if (index > 0) {
                        final prevItem = items[index - 1];
                        final prevDate = DateTime(
                          prevItem.date.year,
                          prevItem.date.month,
                          prevItem.date.day,
                        );
                        if (prevDate == currentDate) isFirstOfDay = false;
                      }

                      bool isLastOfDay = true;
                      if (index < items.length - 1) {
                        final nextItem = items[index + 1];
                        final nextDate = DateTime(
                          nextItem.date.year,
                          nextItem.date.month,
                          nextItem.date.day,
                        );
                        if (nextDate == currentDate) isLastOfDay = false;
                      }

                      jm.TimelinePosition jmPosition =
                          jm.TimelinePosition.middle;
                      rm.TimelinePosition rmPosition =
                          rm.TimelinePosition.middle;
                      if (isFirstOfDay && isLastOfDay) {
                        jmPosition = jm.TimelinePosition.standalone;
                        rmPosition = rm.TimelinePosition.standalone;
                      } else if (isFirstOfDay) {
                        jmPosition = jm.TimelinePosition.start;
                        rmPosition = rm.TimelinePosition.start;
                      } else if (isLastOfDay) {
                        jmPosition = jm.TimelinePosition.end;
                        rmPosition = rm.TimelinePosition.end;
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isFirstOfDay)
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 8,
                                bottom: 24,
                                left: 16,
                              ),
                              child: Text(
                                DateFormat('MMMM d, yyyy').format(currentDate),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                          item.map(
                            milestone: (m) => TimelineNode(
                              milestone: m.data,
                              isHistoricalClosure: false,
                              overridePosition: jmPosition,
                            ),
                            record: (r) => GestureDetector(
                              onLongPress: () {
                                if (view != null) {
                                  _showRemoveRecordDialog(context, view, r.data);
                                }
                              },
                              child: rm.ReportTimelineNode(
                                report: r.data,
                                position: rmPosition,
                                isSelected: false,
                                showEditMenu: false,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                    childCount: items.length + 1, // +1 for loading indicator
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SnapshotOptionsSheet extends ConsumerWidget {
  final MixView view;
  const _SnapshotOptionsSheet({required this.view});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final shareUrl = 'https://healingmilestones.in/snapshot/${view.id}';
    final isExpired = view.expiresAt.isBefore(DateTime.now());
    final expiryText = isExpired
        ? 'Expired on ${DateFormat("MMM d, yyyy 'at' h:mm a").format(view.expiresAt)}'
        : 'Expires on ${DateFormat("MMM d, yyyy 'at' h:mm a").format(view.expiresAt)}';

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor.withValues(alpha: 0.85),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border(
              top: BorderSide(
                color: theme.colorScheme.primary.withValues(alpha: 0.35),
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.4,
                      ),
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: Row(
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
                            icon: const Icon(Icons.close_rounded, size: 22),
                            style: IconButton.styleFrom(
                              padding: const EdgeInsets.all(10),
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
                            'Share Snapshot',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        Text(
                          view.name,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: (isExpired
                                    ? theme.colorScheme.error
                                    : theme.colorScheme.primary)
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isExpired
                                    ? Icons.timer_off_outlined
                                    : Icons.timer_outlined,
                                size: 14,
                                color: isExpired
                                    ? theme.colorScheme.error
                                    : theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                expiryText,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: isExpired
                                      ? theme.colorScheme.error
                                      : theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Scannable QR Card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        QrImageView(
                          data: shareUrl,
                          version: QrVersions.auto,
                          size: 176.0,
                          dataModuleStyle: QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: isExpired ? Colors.grey : Colors.black,
                          ),
                          eyeStyle: QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: isExpired ? Colors.grey : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          isExpired
                              ? 'Snapshot link expired'
                              : 'Scan to view timeline',
                          style: TextStyle(
                            color: isExpired
                                ? Colors.red.shade400
                                : Colors.black54,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Bottom Action Bar matching DirectShareSheet
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(32),
                      ),
                      border: Border(
                        top: BorderSide(
                          color: theme.dividerColor.withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildActionOption(
                            context: context,
                            icon: Icons.link_rounded,
                            label: 'Copy Link',
                            enabled: !isExpired,
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: shareUrl));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Link copied to clipboard'),
                                ),
                              );
                              Navigator.pop(context);
                            },
                          ),
                          _buildActionOption(
                            context: context,
                            icon: Icons.ios_share,
                            label: 'Share via',
                            enabled: !isExpired,
                            onTap: () {
                              Navigator.pop(context);
                              // ignore: deprecated_member_use
                              Share.share(
                                'View my Health Snapshot (${view.name}):\n\n$shareUrl',
                                subject: 'Healing Milestones Health Snapshot',
                              );
                            },
                          ),
                          _buildActionOption(
                            context: context,
                            icon: Icons.monitor,
                            label: 'Share to Web',
                            enabled: !isExpired,
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => QRScanScreen(
                                    targetId: view.id,
                                    targetType: 'snapshot',
                                  ),
                                ),
                              );
                            },
                          ),
                          _buildActionOption(
                            context: context,
                            icon: Icons.qr_code_2_rounded,
                            label: 'QR Code',
                            enabled: !isExpired,
                            onTap: () {
                              Navigator.pop(context);
                              showGeneralDialog(
                                context: context,
                                barrierDismissible: true,
                                barrierLabel: 'Dismiss',
                                barrierColor: Colors.black.withValues(
                                  alpha: 0.9,
                                ),
                                transitionDuration: const Duration(
                                  milliseconds: 300,
                                ),
                                pageBuilder:
                                    (context, animation, secondaryAnimation) {
                                      return QrSharePreview(
                                        id: view.id,
                                        shareUrl: shareUrl,
                                        shareText:
                                            'View my Health Snapshot: ${view.name}',
                                        qrBottomText:
                                            'Scan to view health snapshot',
                                      );
                                    },
                              );
                            },
                          ),
                          _buildActionOption(
                            context: context,
                            icon: Icons.delete_outline_rounded,
                            label: 'Delete',
                            isDestructive: true,
                            onTap: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (c) => AlertDialog(
                                  title: const Text('Delete Snapshot?'),
                                  content: const Text(
                                    'This will instantly break the link. Anyone with the link will no longer see your timeline.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(c, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(c, true),
                                      child: const Text(
                                        'Delete',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                ref
                                    .read(mixViewsProvider.notifier)
                                    .revokeMixView(view.id);
                                if (context.mounted) {
                                  Navigator.pop(context);
                                  if (context.canPop()) {
                                    context.pop();
                                  } else {
                                    context.go('/journey');
                                  }
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool enabled = true,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    final surfaceLight =
        theme.cardTheme.color ?? theme.colorScheme.surfaceContainerHighest;
    final fgColor = isDestructive
        ? theme.colorScheme.error
        : theme.colorScheme.onSurface;

    return Opacity(
      opacity: enabled ? 1.0 : 0.4,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDestructive
                      ? theme.colorScheme.error.withValues(alpha: 0.1)
                      : surfaceLight,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDestructive
                        ? theme.colorScheme.error.withValues(alpha: 0.3)
                        : theme.dividerColor.withValues(alpha: 0.1),
                  ),
                ),
                child: Icon(icon, size: 26, color: fgColor),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontSize: 12,
                  color: fgColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../features/medical_vault/presentation/providers/medical_vault_providers.dart';
import '../../../../features/medical_vault/data/models/medical_vault_models.dart';
import '../../../../features/journey/presentation/widgets/timeline_node.dart';
import '../../../../features/medical_vault/presentation/widgets/report_timeline_node.dart';

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
              view?.name ?? 'Health Snapshot',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              onPressed: () => context.go('/medical-vault'),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: IconButton(
                  icon: const Icon(Icons.share_rounded),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Public link sharing coming soon!'),
                      ),
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
                          Icons.hourglass_empty_rounded,
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
                  horizontal: 20,
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

                      // Check if month/year changed to show date header
                      bool showHeader = false;
                      if (index == 0) {
                        showHeader = true;
                      } else {
                        final prevItem = items[index - 1];
                        final prevDate = prevItem.date;
                        if (item.date.year != prevDate.year ||
                            item.date.month != prevDate.month) {
                          showHeader = true;
                        }
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (showHeader)
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 24,
                                bottom: 24,
                                left: 40,
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: theme
                                      .colorScheme
                                      .surfaceContainerHighest
                                      .withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  DateFormat('MMMM yyyy').format(item.date),
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                            ),

                          item.map(
                            milestone: (m) => TimelineNode(
                              milestone: m.data,
                              isHistoricalClosure: false,
                            ),
                            record: (r) => IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 24.0,
                                      ),
                                      child: ReportTimelineNode(
                                        report: r.data,
                                        position: TimelinePosition.standalone,
                                        isSelected: false,
                                        showEditMenu: false,
                                      ),
                                    ),
                                  ),
                                ],
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

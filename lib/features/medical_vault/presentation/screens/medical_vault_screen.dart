import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:intl/intl.dart';

import '../providers/medical_vault_providers.dart';
import '../widgets/upload_report_overlay.dart';
import '../widgets/report_timeline_node.dart';
import '../../data/models/medical_vault_models.dart';
import 'trends_tab.dart';

class MedicalVaultScreen extends ConsumerStatefulWidget {
  const MedicalVaultScreen({super.key});

  @override
  ConsumerState<MedicalVaultScreen> createState() => _MedicalVaultScreenState();
}

class _MedicalVaultScreenState extends ConsumerState<MedicalVaultScreen> {
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
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(medicalRecordsProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recordsAsync = ref.watch(medicalRecordsProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            'My Medical Vault',
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
          actions: [
            IconButton(
              icon: Icon(Icons.share_rounded, color: theme.colorScheme.primary),
              onPressed: () {
                context.push('/health-snapshot/create');
              },
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(64),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: TabBar(
                  dividerColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    color: theme.colorScheme.primary,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  labelColor: theme.colorScheme.onPrimary,
                  unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  tabs: const [
                    Tab(text: 'Timeline'),
                    Tab(text: 'Dashboard'),
                  ],
                ),
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => UploadReportOverlay.show(context),
          backgroundColor: theme.colorScheme.primary,
          icon: Icon(Icons.add, color: theme.colorScheme.onPrimary),
          label: Text(
            'Add Report',
            style: TextStyle(color: theme.colorScheme.onPrimary),
          ),
        ),
        body: TabBarView(
          children: [
            recordsAsync.when(
              loading: () => Center(
                child: CircularProgressIndicator(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (records) {
                if (records.isEmpty) {
                  return const Center(
                    child: Text(
                      'Your vault is empty.\nUpload medical reports to track your health.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  );
                }

                // Group by encounter date
                final grouped = <DateTime, List<MedicalRecord>>{};
                for (final record in records) {
                  final date = DateTime(
                    record.encounterDate.year,
                    record.encounterDate.month,
                    record.encounterDate.day,
                  );
                  grouped.putIfAbsent(date, () => []).add(record);
                }

                final sortedDates = grouped.keys.toList()
                  ..sort((a, b) => b.compareTo(a));

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(0),
                  itemCount: sortedDates.length + 1, // +1 for loading indicator
                  itemBuilder: (context, index) {
                    if (index == sortedDates.length) {
                      final notifier = ref.read(
                        medicalRecordsProvider.notifier,
                      );
                      if (notifier.isLoadingMore) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      if (!notifier.hasMore && sortedDates.isNotEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text(
                              'No more reports',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }

                    final date = sortedDates[index];
                    final dateRecords = List.of(grouped[date]!)
                      ..sort((a, b) {
                        final cmp = b.encounterDate.compareTo(a.encounterDate);
                        if (cmp != 0) return cmp;
                        return b.createdAt.compareTo(a.createdAt);
                      });

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 12,
                          ),
                          child: Text(
                            DateFormat('MMMM d, yyyy').format(date),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        ...List.generate(dateRecords.length, (i) {
                          final isFirst = i == 0;
                          final isLast = i == dateRecords.length - 1;
                          TimelinePosition position = TimelinePosition.middle;
                          if (dateRecords.length == 1) {
                            position = TimelinePosition.standalone;
                          } else if (isFirst) {
                            position = TimelinePosition.start;
                          } else if (isLast) {
                            position = TimelinePosition.end;
                          }

                          return ReportTimelineNode(
                            report: dateRecords[i],
                            position: position,
                          );
                        }),
                        const SizedBox(height: 16),
                      ],
                    );
                  },
                );
              },
            ),
            const TrendsTab(),
          ],
        ),
      ),
    );
  }
}

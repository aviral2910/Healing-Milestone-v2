import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../providers/medical_vault_providers.dart';
import '../widgets/report_timeline_node.dart';
import '../../data/models/medical_vault_models.dart';

class FullTimelineScreen extends ConsumerStatefulWidget {
  const FullTimelineScreen({super.key});

  @override
  ConsumerState<FullTimelineScreen> createState() => _FullTimelineScreenState();
}

class _FullTimelineScreenState extends ConsumerState<FullTimelineScreen> {
  String _searchQuery = '';

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

  Widget _buildAnim(int idx, Widget child) {
    return AnimationConfiguration.staggeredList(
      position: idx,
      duration: const Duration(milliseconds: 375),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recordsAsync = ref.watch(medicalRecordsProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'All Reports',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.share_rounded, color: theme.colorScheme.primary),
            onPressed: () {
              context.push('/health-snapshot/create');
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64.0),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  icon: Icon(
                    Icons.search,
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.5,
                    ),
                    size: 20,
                  ),
                  hintText: 'Search by category (e.g. lipid, cbc)',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.4,
                    ),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: recordsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (records) {
          final query = _searchQuery.trim().toLowerCase();
          final filteredRecords = records.where((r) {
            if (query.isEmpty) return true;
            final typesString = r.reportTypes.join(' ').toLowerCase();
            return typesString.contains(query);
          }).toList();

          if (filteredRecords.isEmpty) {
            return Center(
              child: Text(
                'No reports found.',
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.6,
                  ),
                  fontWeight: FontWeight.w400,
                ),
              ),
            );
          }

          final grouped = <DateTime, List<MedicalRecord>>{};
          for (final record in filteredRecords) {
            final date = DateTime(
              record.encounterDate.year,
              record.encounterDate.month,
              record.encounterDate.day,
            );
            grouped.putIfAbsent(date, () => []).add(record);
          }

          final sortedDates = grouped.keys.toList()
            ..sort((a, b) => b.compareTo(a));

          return AnimationLimiter(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: sortedDates.length + 1,
              itemBuilder: (context, index) {
                if (index == sortedDates.length) {
                  final notifier = ref.read(medicalRecordsProvider.notifier);
                  if (notifier.isLoadingMore) {
                    return _buildAnim(
                      index,
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    );
                  }
                  if (!notifier.hasMore && sortedDates.isNotEmpty) {
                    return _buildAnim(
                      index,
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            'No more reports',
                            style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.6),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  return _buildAnim(index, const SizedBox.shrink());
                }

                final date = sortedDates[index];
                final dateRecords = List.of(grouped[date]!)
                  ..sort((a, b) {
                    final cmp = b.encounterDate.compareTo(a.encounterDate);
                    if (cmp != 0) return cmp;
                    return b.createdAt.compareTo(a.createdAt);
                  });

                return _buildAnim(
                  index,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 24,
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

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: ReportTimelineNode(
                            report: dateRecords[i],
                            position: position,
                          ),
                        );
                      }),
                      const SizedBox(height: 16),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

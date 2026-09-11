import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/report_timeline_node.dart';
import '../../data/models/medical_vault_models.dart';
import 'full_timeline_screen.dart';
import 'package:go_router/go_router.dart';
import '../widgets/upload_report_overlay.dart';
import 'trends_tab.dart';
import '../providers/medical_vault_providers.dart';

class MedicalVaultScreen extends ConsumerStatefulWidget {
  const MedicalVaultScreen({super.key});

  @override
  ConsumerState<MedicalVaultScreen> createState() => _MedicalVaultScreenState();
}

class _MedicalVaultScreenState extends ConsumerState<MedicalVaultScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => UploadReportOverlay.show(context),
        backgroundColor: theme.colorScheme.primary,
        icon: Icon(Icons.add, color: theme.colorScheme.onPrimary),
        label: Text(
          'Add Report',
          style: TextStyle(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: TrendsTab(bottomWidget: _buildRecentReports(context, ref)),
    );
  }

  Widget _buildRecentReports(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(medicalRecordsProvider);
    final theme = Theme.of(context);

    return recordsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => const SizedBox.shrink(),
      data: (records) {
        if (records.isEmpty) {
          return const SizedBox.shrink();
        }

        final sortedRecords = List<MedicalRecord>.from(records)
          ..sort((a, b) {
            final cmp = b.encounterDate.compareTo(a.encounterDate);
            if (cmp != 0) return cmp;
            return b.createdAt.compareTo(a.createdAt);
          });

        final recentRecords = sortedRecords.take(3).toList();

        final grouped = <DateTime, List<MedicalRecord>>{};
        for (final record in recentRecords) {
          final date = DateTime(
            record.encounterDate.year,
            record.encounterDate.month,
            record.encounterDate.day,
          );
          grouped.putIfAbsent(date, () => []).add(record);
        }

        final sortedDates = grouped.keys.toList()
          ..sort((a, b) => b.compareTo(a));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Reports',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (records.length > 3)
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const FullTimelineScreen(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(50, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'View All',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            ...sortedDates.map((date) {
              final dateRecords = grouped[date]!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    child: Text(
                      DateFormat('MMMM d, yyyy').format(date),
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
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
                  const SizedBox(height: 16), // Gap between dates
                ],
              );
            }).toList(),

            const SizedBox(height: 100),
          ],
        );
      },
    );
  }
}

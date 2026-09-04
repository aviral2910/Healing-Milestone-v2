import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:intl/intl.dart';

import '../providers/medical_vault_providers.dart';
import '../widgets/upload_report_overlay.dart';
import '../../data/models/medical_vault_models.dart';

class MedicalVaultScreen extends ConsumerStatefulWidget {
  const MedicalVaultScreen({super.key});

  @override
  ConsumerState<MedicalVaultScreen> createState() => _MedicalVaultScreenState();
}

class _MedicalVaultScreenState extends ConsumerState<MedicalVaultScreen> {


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recordsAsync = ref.watch(medicalRecordsProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('My Medical Vault', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold)),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => UploadReportOverlay.show(context),
        backgroundColor: theme.colorScheme.primary,
        icon: Icon(Icons.add, color: theme.colorScheme.onPrimary),
        label: Text('Add Report', style: TextStyle(color: theme.colorScheme.onPrimary)),
      ),
      body: recordsAsync.when(
        loading: () => Center(child: CircularProgressIndicator(color: theme.colorScheme.onSurface)),
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
            final date = DateTime(record.encounterDate.year, record.encounterDate.month, record.encounterDate.day);
            grouped.putIfAbsent(date, () => []).add(record);
          }
          
          final sortedDates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sortedDates.length,
            itemBuilder: (context, index) {
              final date = sortedDates[index];
              final dateRecords = grouped[date]!;
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      DateFormat('MMMM d, yyyy').format(date),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  ...dateRecords.map((r) => Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(r.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () {
                                  ref.read(medicalRecordsProvider.notifier).deleteReport(r.id);
                                },
                              ),
                            ],
                          ),
                          Text('Added ${DateFormat('MMM d').format(r.createdAt)}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: r.files.map((file) {
                              final isPdf = file.fileType.contains('pdf');
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isPdf ? Icons.picture_as_pdf : Icons.image,
                                      color: theme.colorScheme.primary,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      file.fileName,
                                      style: TextStyle(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  )),
                  const SizedBox(height: 16),
                ],
              );
            },
          );
        },
      ),
    );
  }
}





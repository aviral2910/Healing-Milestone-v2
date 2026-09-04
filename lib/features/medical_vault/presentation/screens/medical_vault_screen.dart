import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

import '../providers/medical_vault_providers.dart';
import '../../data/models/medical_vault_models.dart';

class MedicalVaultScreen extends ConsumerStatefulWidget {
  const MedicalVaultScreen({super.key});

  @override
  ConsumerState<MedicalVaultScreen> createState() => _MedicalVaultScreenState();
}

class _MedicalVaultScreenState extends ConsumerState<MedicalVaultScreen> {
  Future<void> _pickAndUploadReport() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
    );

    if (result == null || result.files.single.path == null) return;
    
    final file = File(result.files.single.path!);
    final fileName = result.files.single.name;

    if (!mounted) return;
    
    // Show dialog to get Encounter Date and Title
    final details = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _ReportDetailsDialog(fileName: fileName),
    );
    
    if (details == null) return;

    ref.read(medicalRecordsNotifierProvider.notifier).uploadReport(
      file: file,
      fileName: fileName,
      title: details['title'],
      encounterDate: details['encounterDate'],
    );
  }

  @override
  Widget build(BuildContext context) {
    final recordsAsync = ref.watch(medicalRecordsNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('My Medical Vault', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _pickAndUploadReport,
        backgroundColor: Colors.black,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Report', style: TextStyle(color: Colors.white)),
      ),
      body: recordsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.black)),
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
                    child: ListTile(
                      leading: Icon(
                        r.fileType.contains('pdf') ? Icons.picture_as_pdf : Icons.image,
                        color: Colors.blueAccent,
                        size: 32,
                      ),
                      title: Text(r.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('Added ${DateFormat('MMM d').format(r.createdAt)}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () {
                          ref.read(medicalRecordsNotifierProvider.notifier).deleteReport(r.id);
                        },
                      ),
                      onTap: () {
                        // Launch URL or show preview
                      },
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

class _ReportDetailsDialog extends StatefulWidget {
  final String fileName;
  const _ReportDetailsDialog({required this.fileName});

  @override
  State<_ReportDetailsDialog> createState() => _ReportDetailsDialogState();
}

class _ReportDetailsDialogState extends State<_ReportDetailsDialog> {
  final _titleController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Report Details'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Title (e.g., Brain MRI)'),
          ),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('Encounter Date'),
            subtitle: Text(DateFormat('MMM d, yyyy').format(_selectedDate)),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                setState(() => _selectedDate = date);
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
          onPressed: () {
            if (_titleController.text.isEmpty) return;
            Navigator.pop(context, {
              'title': _titleController.text,
              'encounterDate': _selectedDate,
            });
          },
          child: const Text('Upload', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

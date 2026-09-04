import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../providers/medical_vault_providers.dart';

class MixViewBuilderScreen extends ConsumerStatefulWidget {
  final String journeyId;
  const MixViewBuilderScreen({super.key, required this.journeyId});

  @override
  ConsumerState<MixViewBuilderScreen> createState() => _MixViewBuilderScreenState();
}

class _MixViewBuilderScreenState extends ConsumerState<MixViewBuilderScreen> {
  final _nameController = TextEditingController();
  final Set<String> _selectedReportIds = {};
  int _selectedDuration = 24; // Default to 24 hours
  bool _isLoading = false;

  final List<Map<String, dynamic>> _durations = [
    {'label': '1 Hour', 'value': 1},
    {'label': '24 Hours', 'value': 24},
    {'label': '7 Days', 'value': 168},
    {'label': '30 Days (Max)', 'value': 720},
  ];

  Future<void> _generateView() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a name for this view')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final newView = await ref.read(mixViewsProvider.notifier).createMixView(
        name: _nameController.text.trim(),
        journeyId: widget.journeyId,
        selectedReportIds: _selectedReportIds.toList(),
        durationHours: _selectedDuration,
      );
      
      if (!mounted) return;
      
      // Navigate to the QR Share Screen
      context.pushReplacement('/medical-vault/share/${newView.id}');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating view: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recordsAsync = ref.watch(medicalRecordsProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Create Clinical View', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold)),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: _isLoading ? null : _generateView,
            child: _isLoading 
                ? CircularProgressIndicator(color: theme.colorScheme.onPrimary)
                : Text('Generate QR Code', style: TextStyle(color: theme.colorScheme.onPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Name this View', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'e.g., Dr. Smith Cardiology Consult',
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 24),
            
            const Text('Link Expiry (Self-Destruct)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  isExpanded: true,
                  value: _selectedDuration,
                  items: _durations.map((d) => DropdownMenuItem<int>(
                    value: d['value'] as int,
                    child: Text(d['label'] as String),
                  )).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedDuration = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            const Text('Include Medical Reports', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Text('Select which private reports to merge into this timeline.', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
            
            recordsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error loading reports: $e'),
              data: (records) {
                if (records.isEmpty) return const Text('No reports in your vault.', style: TextStyle(fontStyle: FontStyle.italic));
                
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final r = records[index];
                    final isSelected = _selectedReportIds.contains(r.id);
                    
                    return CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(r.reportTypes.join(', '), style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(DateFormat('MMM d, yyyy').format(r.encounterDate)),
                      value: isSelected,
                      activeColor: theme.colorScheme.primary,
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            _selectedReportIds.add(r.id);
                          } else {
                            _selectedReportIds.remove(r.id);
                          }
                        });
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

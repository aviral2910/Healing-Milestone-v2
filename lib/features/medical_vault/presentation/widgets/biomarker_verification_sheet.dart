import 'package:flutter/material.dart';
import '../../data/models/biomarker_model.dart';
import '../../data/repositories/medical_vault_repository.dart';

class BiomarkerVerificationSheet extends StatefulWidget {
  final List<BiomarkerModel> initialBiomarkers;
  final String recordId;
  final MedicalVaultRepository repository;

  const BiomarkerVerificationSheet({
    super.key,
    required this.initialBiomarkers,
    required this.recordId,
    required this.repository,
  });

  @override
  State<BiomarkerVerificationSheet> createState() => _BiomarkerVerificationSheetState();
}

class _BiomarkerVerificationSheetState extends State<BiomarkerVerificationSheet> {
  late List<BiomarkerModel> _biomarkers;
  bool _isSaving = false;
  
  @override
  void initState() {
    super.initState();
    // Create editable copies
    _biomarkers = widget.initialBiomarkers.map((b) => b.copyWith()).toList();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      await widget.repository.saveBiomarkers(widget.recordId, _biomarkers);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            children: [
              Icon(Icons.auto_awesome, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Verify AI Results',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Please verify the extracted data before saving.',
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.separated(
              itemCount: _biomarkers.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final biomarker = _biomarkers[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              biomarker.aiPredictedStandardName ?? biomarker.rawName,
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            if (biomarker.aiPredictedStandardName != null && biomarker.aiPredictedStandardName != biomarker.rawName)
                              Text(
                                'Printed as: ${biomarker.rawName}',
                                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 1,
                        child: _buildInput(biomarker, index),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        biomarker.rawUnit ?? '',
                        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Approve & Save'),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }

  Widget _buildInput(BiomarkerModel biomarker, int index) {
    if (biomarker.resultType == 'binary') {
      return DropdownButtonFormField<String>(
        value: biomarker.valueText,
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          border: OutlineInputBorder(),
        ),
        items: const [
          DropdownMenuItem(value: 'Positive', child: Text('Positive')),
          DropdownMenuItem(value: 'Negative', child: Text('Negative')),
          DropdownMenuItem(value: 'Reactive', child: Text('Reactive')),
          DropdownMenuItem(value: 'Non-Reactive', child: Text('Non-Reactive')),
        ],
        onChanged: (val) {
          setState(() {
            _biomarkers[index] = biomarker.copyWith(valueText: val);
          });
        },
      );
    }
    
    // Numeric input
    return TextFormField(
      initialValue: biomarker.valueNumeric?.toString() ?? '',
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: const InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: OutlineInputBorder(),
      ),
      onChanged: (val) {
        final parsed = double.tryParse(val);
        setState(() {
          _biomarkers[index] = biomarker.copyWith(valueNumeric: parsed);
        });
      },
    );
  }
}
